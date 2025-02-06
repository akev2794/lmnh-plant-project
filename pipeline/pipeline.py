"""
This script is for the ETL process for the LMNH plant data.
The file swill pull data for the API, clean it
and upload it to the AWS relational database.
"""

# Native Imports
from time import sleep
from os import environ as ENV

# Third-party imports
import pandas as pd
import pyodbc


# Local imports
from dotenv import load_dotenv

from extract import create_dataframe
from transform import process_plant_data, format_plant_data


def load_to_recording(data: list[tuple], connection: pyodbc.Connection):
    """Upload the data to the recording table."""
    cur = conn.cursor()
    sql = """
            INSERT INTO beta.recording
            (recording.plant_id, recording.soil_moisture, recording.temperature, recording.last_watered, recording.taken_at)
            VALUES (?, ?, ?, ?, ?)
            """
    cur.executemany(sql, data)
    conn.commit()
    cur.close()


if __name__ == "__main__":
    load_dotenv()

    conn = pyodbc.connect(f"""
        DRIVER={{ODBC Driver 18 for SQL Server}};
        SERVER={ENV["DB_HOST"]},{ENV["DB_PORT"]};
        DATABASE={ENV["DB_NAME"]};
        UID={ENV["DB_USER"]};
        PWD={ENV["DB_PASSWORD"]};
        TrustServerCertificate=yes;
    """)

    # upload 10 over 10 minutes
    for _ in range(10):
        plants_df = create_dataframe()
        plants_df = process_plant_data(plants_df, conn)
        plants_data = format_plant_data(plants_df)
        load_to_recording(plants_data, conn)
        print("loaded")
        

    conn.close()
