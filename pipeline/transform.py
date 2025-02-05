"""
This script is for transforming the LMNH data obtained from the extract.py file.
The script will clean the data
and prepare it for uploading to the AWS relational database.
"""
from datetime import datetime
from os import environ as ENV

import pandas as pd
from sqlalchemy import create_engine, text, Engine
from sqlalchemy.engine import URL


def safe_parse_datetime(date_str: str) -> datetime:
    try:
        return datetime.strptime(date_str, "%a, %d %b %Y %H:%M:%S GMT")
    except ValueError:
        return pd.NA 


def make_engine() -> Engine:
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


def get_plant_ids(engine: Engine) -> dict:
    """Returns available plant ids."""
    query = """SELECT plant_id
    FROM beta.plant;"""
    with engine.connect() as conn:
        result = conn.execute(text(query))
        plant_ids = [row[0] for row in result.fetchall()]
        return plant_ids


def process_plant_data(df: pd.DataFrame) -> pd.DataFrame:
    """Processes data, returning DataFrame with plant_id, soil_moisture, temperature, taken_at."""
    df = df[["plant_id", "soil_moisture", "temperature", "last_watered"]].copy()
    current_plant_ids = get_plant_ids(make_engine())
    df = df[df["plant_id"].isin(current_plant_ids)]
    df["last_watered"] = pd.to_datetime(df["last_watered"].astype(str).apply(safe_parse_datetime))
    df = df.dropna()
    df["soil_moisture"] = df["soil_moisture"].round(2)
    df["temperature"] = df["soil_moisture"].round(2)
    timestamp = datetime.now()
    df["taken_at"] = timestamp

    return df