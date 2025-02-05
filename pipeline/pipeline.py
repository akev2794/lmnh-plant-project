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
import pymssql


# Local imports
from dotenv import load_dotenv

from extract import create_dataframe
from transform import process_plant_data


def load_to_recording(df: pd.DataFrame, conn: pymssql.Connection):
    """Upload the data to the recording table."""
    for col in list(df.columns):
        if col not in ["plant_id", "soil_moisture", "temperature", "last_watered", "taken_at"]:
            raise ValueError("Invalid column names.")
        
    if df.empty:
        raise ValueError("Empty dataframe")

    cur = conn.cursor()
    sql = """
            INSERT INTO beta.recording
            (recording.plant_id, recording.soil_moisture, recording.temperature, recording.last_watered, recording.taken_at)
            VALUES (%s, %s, %s, %s, %s)
            """
    cur.executemany(sql, df.to_dict())
    conn.commit()
    cur.close()

#    (recording.plant_id, recording.soil_moisture, recording.temperature, recording.last_watered, recording.taken_at)


if __name__ == "__main__":
    load_dotenv()
    conn = pymssql.connect(
        server=ENV["DB_HOST"],
        user=ENV["DB_USER"],
        password=ENV["DB_PASSWORD"],
        database=ENV["DB_NAME"],
        port=ENV["DB_PORT"]
    )


    # upload 10 over 10 minutes
    for _ in range(10):
        plants_df = create_dataframe()
        plants_df = process_plant_data(plants_df)
        print(plants_df.to_dict())
        # load_to_recording(plants_df, conn)
        # print("loaded")
        sleep(60)
    
    conn.close()
