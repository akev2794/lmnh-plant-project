"""
This script is for transforming the LMNH data obtained from the extract.py file.
The script will clean the data
and prepare it for uploading to the AWS relational database.
"""

# Native imports
from datetime import datetime

# Third-party imports
import pandas as pd
import pyodbc


def last_watered_safe_parse_datetime(date_str: str) -> datetime:
    """Converts valid last watered dates to datetime objects."""
    try:
        date = datetime.strptime(date_str, "%a, %d %b %Y %H:%M:%S GMT")
        if date > datetime.now():
            return pd.NA
        return datetime.strptime(date_str, "%a, %d %b %Y %H:%M:%S GMT")

    except ValueError:
        return pd.NA


def get_plant_ids(connection: pyodbc.Connection) -> dict:
    """Returns available plant ids."""
    query = """SELECT plant_id
    FROM beta.plant;"""
    with connection.cursor() as cur:
        result = cur.execute(query)
        plant_ids = [row[0] for row in result.fetchall()]
        return plant_ids


def process_plant_data(df: pd.DataFrame, connection: pyodbc.Connection) -> pd.DataFrame:
    """Processes data, returning DataFrame with plant_id, soil_moisture, temperature, taken_at."""
    df = df[["plant_id", "soil_moisture", "temperature", "last_watered"]].copy()
    current_plant_ids = get_plant_ids(connection)
    df = df[df["plant_id"].isin(current_plant_ids)]
    df["last_watered"] = pd.to_datetime(df["last_watered"].astype(str).apply(
        last_watered_safe_parse_datetime)).astype("datetime64[s]")
    df = df.dropna()
    df["soil_moisture"] = df["soil_moisture"].round(2).astype("float64")
    df["temperature"] = df["temperature"].round(2).astype("float64")
    timestamp = datetime.now()
    df["taken_at"] = timestamp
    df["taken_at"] = df["taken_at"].astype("datetime64[s]")
    df["plant_id"] = df["plant_id"].astype("int64")

    return df


def format_plant_data(df: pd.DataFrame):
    """Creates a list of values for uploads."""
    rows = df.to_dict(orient="records")
    return [(row["plant_id"], row["soil_moisture"],
            row["temperature"], row["last_watered"],
            row["taken_at"])  for row in rows]
