from os import environ as ENV
from datetime import datetime
import pandas as pd
from sqlalchemy import create_engine, Engine
from sqlalchemy.engine import URL
from dotenv import load_dotenv


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


def get_data():
    query = """
WITH LastThreeReadings AS (
    SELECT 
        r.plant_id,
        r.soil_moisture,
        r.temperature,
        r.taken_at,
        p.min_temp,
        p.max_temp,
        p.min_moisture,
        p.max_moisture,
        ROW_NUMBER() OVER (PARTITION BY r.plant_id ORDER BY r.taken_at DESC) AS rn
    FROM beta.recording r
    JOIN beta.plant p ON r.plant_id = p.plant_id
),
FilteredReadings AS (
    SELECT
        plant_id,
        soil_moisture,
        temperature,
        min_temp,
        max_temp,
        min_moisture,
        max_moisture
    FROM LastThreeReadings
    WHERE rn <= 3
    )
    SELECT 
    plant_id,
    CASE
        WHEN SUM(CASE WHEN temperature < min_temp THEN 1 WHEN temperature > max_temp THEN 1 ELSE 0 END) > 1 THEN 'Temperature out of range'
        ELSE 'Temperature within range'
    END AS temperature_status,

    CASE
        WHEN SUM(CASE WHEN soil_moisture < min_moisture THEN 1 WHEN soil_moisture > max_moisture THEN 1 ELSE 0 END) > 1 THEN 'Moisture out of range'
        ELSE 'Moisture within range'
    END AS moisture_status
    FROM FilteredReadings
    GROUP BY plant_id
    ORDER BY plant_id;
    """
    engine = make_engine()
    with engine.connect() as connection:
        result = connection.execute(query)
    for row in result:
        print(row)


if __name__ == "__main__":
    load_dotenv()
    get_data()
