"""
This script is for the ETL process for the LMNH plant data.
The file swill pull data for the API, clean it
and upload it to the AWS relational database.
"""

# Native Imports
from time import sleep
from os import environ as ENV
import logging

# Third-party imports
import pandas as pd
import pyodbc


# Local imports
from dotenv import load_dotenv

from extract import create_dataframe
from transform import process_plant_data, format_plant_data


def create_env_connection():
    """Creates pyodbc connection based on environment variables."""
    try:
        conn = pyodbc.connect(f"""
        DRIVER={{ODBC Driver 18 for SQL Server}};
        SERVER={ENV["DB_HOST"]},{ENV["DB_PORT"]};
        DATABASE={ENV["DB_NAME"]};
        UID={ENV["DB_USER"]};
        PWD={ENV["DB_PASSWORD"]};
        TrustServerCertificate=yes;
    """)
        return conn
    except pyodbc.Error as e:
        error_msg = e
        logging.error("Error connecting to database: %s", error_msg)
        raise


def load_to_recording(data: list[tuple], conn: pyodbc.Connection):
    """Upload the data to the recording table."""
    try:
        cur = conn.cursor()
        sql = """
                INSERT INTO beta.recording
                (recording.plant_id, recording.soil_moisture, recording.temperature, recording.last_watered, recording.taken_at)
                VALUES (?, ?, ?, ?, ?)
                """
        cur.executemany(sql, data)
        conn.commit()
        cur.close()
    except pyodbc.Error as e:
        error_msg = e
        logging.error("Error uploading to database: %s", error_msg)


def run_pipeline(conn: pyodbc.Connection) -> None:
    """Executes pipeline."""
    plants_df = create_dataframe()
    plants_df = process_plant_data(plants_df, conn)
    plants_data = format_plant_data(plants_df)
    load_to_recording(plants_data, conn)
    logging.info("Upload complete!")


if __name__ == "__main__":
    load_dotenv()
    with create_env_connection() as connection:
        # upload 10 over 10 minutes
        for _ in range(10):
            run_pipeline(connection)
            sleep(40)
