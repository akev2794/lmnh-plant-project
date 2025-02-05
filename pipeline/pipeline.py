"""
This script is for the ETL process for the LMNH plant data.
The file swill pull data for the API, clean it
and upload it to the AWS relational database.
"""

# Native imports
from os import environ as ENV
from datetime import datetime

# Third-party imports
import pandas as pd
from sqlalchemy import create_engine, Engine
from sqlalchemy.engine import URL


# Local imports
from dotenv import load_dotenv
from extract import create_dataframe
# from transform import ...


def make_engine():
    """Creates sqlalchemy engine."""
    connection_string = f"""
        DRIVER={{ODBC Driver 18 for SQL Server}};
        SERVER={ENV["DB_HOST"]},{ENV["DB_PORT"]};
        DATABASE={ENV["DB_NAME"]};
        UID={ENV["DB_USER"]};
        PWD={ENV["DB_PASSWORD"]};
        TrustServerCertificate=Yes"""

    connection_url = URL.create(
        "mssql+pyodbc", query={"odbc_connect": connection_string}
    )
    return create_engine(connection_url)


def load_to_recording(df: pd.DataFrame, alchemy_engine: Engine):
    """Upload the data to the databse."""
    for col in list(df.columns):
        if col not in ['plant_id', 'soil_moisture', 'temperature', 'taken_at']:
            raise ValueError("Invalid column names.")
    df.to_sql('recording', alchemy_engine, schema='beta', if_exists='append', index=False)


def load_to_incident(df: pd.DataFrame, alchemy_engine: Engine):
    """Upload the data to the databse."""
    for col in list(df.columns):
        if col not in ['plant_id', 'incident_type', 'incident_at']:
            raise ValueError("Invalid column names.")
    df.to_sql('recording', alchemy_engine, schema='beta', if_exists='append', index=False)


def transform_data():
    """Transform the extracted data."""
    pass


if __name__ == "__main__":
    # Initialise
    load_dotenv()
    engine = make_engine()


    # Extract
    # plants_df = create_dataframe()


    # Transform - EXAMPLE
    # plants_df = transform(plants_df)


    # Load
    load_to_recording(plant_df, engine)
