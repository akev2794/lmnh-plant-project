"""
This script is for transforming the LMNH data obtained from the extract.py file.
The script will clean the data
and prepare it for uploading to the AWS relational database.
"""
from datetime import datetime

import pandas as pd


def safe_parse_datetime(date_str):
    try:
        return datetime.strptime(date_str, "%a, %d %b %Y %H:%M:%S GMT")
    except ValueError:
        return pd.NA 


def process_plant_data(df: pd.DataFrame) -> pd.DataFrame:
    """Processes data, returning DataFrame with plant_id, soil_moisture, temperature, taken_at."""
    df = df[["plant_id", "soil_moisture", "temperature", "last_watered"]].copy()
    df["last_watered"] = pd.to_datetime(df["last_watered"].astype(str).apply(safe_parse_datetime))
    df = df.dropna()
    df["soil_moisture"] = df["soil_moisture"].round(2)
    df["temperature"] = df["soil_moisture"].round(2)
    timestamp = datetime.now()
    df["taken_at"] = timestamp

    return df[["plant_id", "soil_moisture", "temperature", "taken_at", "last_watered"]]