"""A module that takes the plant readings and incidents from the 
last 24 hours and archives them as parquet files in S3."""
#pylint: disable=import-error, unused-argument, c-extension-no-member
from os import environ as ENV, remove
from datetime import datetime, timedelta
import pyodbc
import boto3
import pandas as pd
from dotenv import load_dotenv

def make_connection():
    """Creates a database connection using pyodbc."""

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


def get_time():
    """Gets the previous day's time."""
    return datetime.now() - timedelta(days=1)


def get_data_for_last_24_hours(connection: pyodbc.Connection):
    """Fetches the recording data for the last 24 hours."""
    query = """
    SELECT plant_id, soil_moisture, temperature, taken_at
    FROM beta.recording
    WHERE taken_at >= ?
    """

    timeframe = get_time()

    with connection.cursor() as cursor:
        cursor.execute(query, timeframe)
        rows = cursor.fetchall()

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


def generate_hourly_averages(df):
    """Generates average temperature and moisture per plant per hour."""
    df['hour'] = df['taken_at'].dt.floor('H')
    df_hourly = df.groupby(['plant_id', 'hour']).agg(
        average_temperature=('temperature', 'mean'),
        average_moisture=('soil_moisture', 'mean')
    ).reset_index()

    return df_hourly


def get_historical_incidents(connection: pyodbc.Connection):
    """Fetch incidents from the last 24 hours, join with plant and botanist tables"""
    query = """
    SELECT
        i.plant_id,
        i.incident_at,
        i.incident_type,
        p.botanist_id
    FROM beta.incident i
    JOIN beta.plant p ON i.plant_id = p.plant_id
    JOIN beta.botanist b ON p.botanist_id = b.botanist_id
    WHERE i.incident_at >= ?;
    """

    timeframe = get_time()

    with connection.cursor() as cursor:
        cursor.execute(query, timeframe)
        rows = cursor.fetchall()

    data = []
    for row in rows:
        data.append({
            'plant_id': row.plant_id,
            'incident_at': row.incident_at,
            'incident_type': row.incident_type,
            'botanist_id': row.botanist_id
        })

    df = pd.DataFrame(data)
    return df


def get_filename(df, base_name):
    """Produce filename depending on date"""
    previous_full_date = get_time()
    date_only = previous_full_date.strftime('%Y-%m-%d')
    filename = f"{base_name}_{date_only}.parquet"
    return filename


def save_to_parquet(df, base_name):
    """Saves the DataFrame to a Parquet file in /tmp directory."""
    file_name = get_filename(df, base_name)
    file_path = f"/tmp/{file_name}"
    df.to_parquet(file_path, engine='pyarrow')
    return file_path


def upload_to_s3(file_path, bucket_name, s3_key):
    """Uploads the file to S3."""
    s3_client = boto3.client('s3')
    s3_client.upload_file(file_path, bucket_name, s3_key)
    print(f"File uploaded to S3: {bucket_name}/{s3_key}")


def handler(event=None, context=None):
    """Lambda handler function."""
    load_dotenv()
    conn = make_connection()

    if conn:
        incident_df = get_historical_incidents(conn)
        df = get_data_for_last_24_hours(conn)
        df_hourly = generate_hourly_averages(df)
        recording_file_path = save_to_parquet(
            df_hourly, "plant_recordings")
        incident_file_path = save_to_parquet(
            incident_df, "plant_incidents")
        bucket_name = ENV["S3_BUCKET"]
        s3_recording_key = get_filename(
            df_hourly, "plant_recordings")
        s3_incident_key = get_filename(
            incident_df, "plant_incidents")
        upload_to_s3(recording_file_path, bucket_name, s3_recording_key)
        upload_to_s3(incident_file_path, bucket_name, s3_incident_key)
        remove(recording_file_path)
        remove(incident_file_path)
        conn.close()
        return {
            'statusCode': 200,
            'body': "Files uploaded to S3 successfully."
        }
    return {
        'statusCode': 500,
        'body': "Failed to connect to the database."
    }
