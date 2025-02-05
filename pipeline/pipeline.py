"""
This script is for the ETL process for the LMNH plant data.
The file swill pull data for the API, clean it
and upload it to the AWS relational database.
"""

# Third-party imports
import pandas as pd
from sqlalchemy import Engine


# Local imports
from dotenv import load_dotenv

from extract import create_dataframe
from transform import process_plant_data, make_engine


def load_to_recording(df: pd.DataFrame, alchemy_engine: Engine):
    """Upload the data to the recording table."""
    for col in list(df.columns):
        if col not in ["plant_id", "soil_moisture", "temperature", "last_watered", "taken_at"]:
            raise ValueError("Invalid column names.")
        
    if df.empty:
        raise ValueError("Empty dataframe")
    
    df.to_sql("recording", alchemy_engine, schema="beta", if_exists="append", index=False)


if __name__ == "__main__":
    load_dotenv()
    engine = make_engine()
    plants_df = create_dataframe()
    plants_df = process_plant_data(plants_df)
    load_to_recording(plants_df, engine)
