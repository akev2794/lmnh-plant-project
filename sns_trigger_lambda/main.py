from os import environ as ENV
from datetime import datetime, timedelta
import pandas as pd
from dotenv import load_dotenv
import pyodbc
import json


def make_connection():
    """Creates a database connection using pyodbc."""
    load_dotenv()

    try:
        conn = pyodbc.connect(f"""
                DRIVER={{ODBC Driver 18 for SQL Server}};
                SERVER={ENV["DB_HOST"]},{ENV["DB_PORT"]};
                DATABASE={ENV["DB_NAME"]};
                UID={ENV["DB_USER"]};
                PWD={ENV["DB_PASSWORD"]};
                TrustServerCertificate=yes;
            """)

        print("Database connection successful!")
        return conn
    except pyodbc.Error as e:
        print("Error while connecting to the database:", e)
        return None


def get_last_three_readings(connection: pyodbc.Connection):
    """Gets the last three plant recordings from the database"""
    query = """
WITH LastThreeReadings AS (
    SELECT
        r.plant_id,
        r.soil_moisture,
        r.temperature,
        r.taken_at,
        ROW_NUMBER() OVER (PARTITION BY r.plant_id ORDER BY r.taken_at DESC) AS rn
    FROM beta.recording r
)
SELECT
    plant_id,
    soil_moisture,
    temperature,
    taken_at
FROM LastThreeReadings
WHERE rn <= 3
ORDER BY plant_id, taken_at DESC;
    """

    cursor = connection.cursor()
    cursor.execute(query)
    rows = cursor.fetchall()
    cursor.close()
    data = []
    for row in rows:
        data.append({
            'plant_id': row.plant_id,
            'soil_moisture': row.soil_moisture,
            'temperature': row.temperature,
            'taken_at': row.taken_at
        })
    df = pd.DataFrame(data)

    return df


def get_ranges(connection: pyodbc.Connection):
    """Get the ranges for temperature and moisture from the database"""
    query = """
            SELECT min_temp, max_temp, min_moisture, max_moisture FROM beta.plant;
            """

    cursor = connection.cursor()
    cursor.execute(query)
    row = cursor.fetchone()
    cursor.close()
    return row


def get_incidents(df, connection):
    """Get the temperature and moisture plant recordings that are not within the defined range"""
    min_max_values = get_ranges(connection)
    min_temp, max_temp, min_moisture, max_moisture = min_max_values
    df['out_of_temp_range'] = (df['temperature'] < min_temp) | (
        df['temperature'] > max_temp)
    df['out_of_moisture_range'] = (df['soil_moisture'] < min_moisture) | (
        df['soil_moisture'] > max_moisture)
    df_out_of_range = df.groupby('plant_id').filter(
        lambda group: (group['out_of_temp_range'].all()
                       or group['out_of_moisture_range'].all())
    )
    df_out_of_range = df_out_of_range.drop(
        columns=['out_of_temp_range', 'out_of_moisture_range'])

    return df_out_of_range


def get_out_of_range_type(row):
    """Establish whether the plant reading has the temperature, moisture or both out of range"""
    if row['out_of_temp_range'] and row['out_of_moisture_range']:
        return 'both'
    elif row['out_of_temp_range']:
        return 'temperature'
    elif row['out_of_moisture_range']:
        return 'moisture'
    else:
        return None


def check_existing_incident(plant_id, incident_type, connection: pyodbc.Connection):
    """Check if an incident for the plant and incident type has been recorded in the last 15 minutes."""
    cursor = connection.cursor()
    query = """
    SELECT 1
    FROM beta.incident
    WHERE plant_id = ? 
    AND incident_type = ?
    AND incident_at >= ?
    """
    time_threshold = datetime.now() - timedelta(minutes=15)
    cursor.execute(query, (plant_id, incident_type, time_threshold))
    result = cursor.fetchone()
    cursor.close()
    return result is not None


def format_data(df, connection):
    """Takes in plant readings and the min and max ranges and makes the relevant columns in a DataFrame"""
    min_max_values = get_ranges(connection)
    min_temp, max_temp, min_moisture, max_moisture = min_max_values

    df['out_of_temp_range'] = (df['temperature'] < min_temp) | (
        df['temperature'] > max_temp)
    df['out_of_moisture_range'] = (df['soil_moisture'] < min_moisture) | (
        df['soil_moisture'] > max_moisture)
    df_out_of_range = df.groupby('plant_id').filter(
        lambda group: (group['out_of_temp_range'].all()
                       or group['out_of_moisture_range'].all())
    )

    df_out_of_range['out_of_range_type'] = df_out_of_range.apply(
        get_out_of_range_type, axis=1)

    df_last_reading = df_out_of_range.groupby('plant_id').last().reset_index()

    df_last_reading['temperature_reading'] = df_last_reading.apply(
        lambda row: row['temperature'] if row['out_of_range_type'] == 'temperature' or row['out_of_range_type'] == 'both' else None,
        axis=1
    )
    df_last_reading['soil_moisture_reading'] = df_last_reading.apply(
        lambda row: row['soil_moisture'] if row['out_of_range_type'] == 'moisture' or row['out_of_range_type'] == 'both' else None,
        axis=1
    )

    df_last_reading_details = df_last_reading[[
        'plant_id', 'out_of_range_type', 'taken_at', 'temperature_reading', 'soil_moisture_reading']]
    records_to_insert = []

    for _, record in df_last_reading_details.iterrows():
        plant_id = record['plant_id']
        out_of_range_type = record['out_of_range_type']
        if check_existing_incident(plant_id, out_of_range_type, connection):
            continue
        records_to_insert.append(record)
    df_filtered = pd.DataFrame(records_to_insert)
    return df_filtered


def format_json(df):
    """Takes a DataFrame and converts it into JSON"""
    df_json = df.to_dict(orient='records')
    return json.dumps(df_json, default=str)


def insert_incidents(json_data, connection: pyodbc.Connection):
    """Insert the incidents into the incident table"""
    cursor = connection.cursor()

    records = json.loads(json_data)

    for record in records:

        plant_id = record['plant_id']
        out_of_range_type = record['out_of_range_type']
        taken_at = record['taken_at']
        if '.' in taken_at:
            taken_at = taken_at.split('.')
            taken_at = datetime.strptime(taken_at[0], '%Y-%m-%d %H:%M:%S')
        else:
            taken_at = datetime.strptime(taken_at, '%Y-%m-%d %H:%M:%S')
        incident_type = out_of_range_type
        query = """
        INSERT INTO beta.incident (plant_id, incident_type, incident_at)
        VALUES (?, ?, ?)
        """
        cursor.execute(query, (plant_id, incident_type, taken_at))
    connection.commit()
    cursor.close()


def lambda_handler(event=None, context=None):
    """AWS Lambda handler function."""
    conn = make_connection()

    if not conn:
        return {
            'statusCode': 500,
            'body': json.dumps('Error connecting to the database.')
        }

    df_last_three = get_last_three_readings(conn)
    df_out_of_range = format_data(df_last_three, conn)
    json_data = format_json(df_out_of_range)
    insert_incidents(json_data, conn)
    return {
        'shouldSendEmail': True,
        'statusCode': 200,
        'body': json_data
    }


if __name__ == "__main__":
    load_dotenv()
    print(lambda_handler(None, None))
