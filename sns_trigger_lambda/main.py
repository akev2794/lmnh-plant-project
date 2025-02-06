from os import environ as ENV
from datetime import datetime
import pandas as pd
from sqlalchemy import create_engine, Engine
from sqlalchemy.engine import URL
from dotenv import load_dotenv
import pyodbc


def make_engine():
    """Creates sqlalchemy engine."""
    conn = pyodbc.connect(f"""
        DRIVER={{ODBC Driver 18 for SQL Server}};
        SERVER={ENV["DB_HOST"]},{ENV["DB_PORT"]};
        DATABASE={ENV["DB_NAME"]};
        UID={ENV["DB_USER"]};
        PWD={ENV["DB_PASSWORD"]};
        TrustServerCertificate=yes;
    """)
    return conn


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
        taken_at,
        min_temp,
        max_temp,
        min_moisture,
        max_moisture
    FROM LastThreeReadings
    WHERE rn <= 3
),
OutOfRangeReadings AS (
    SELECT 
        plant_id,
        taken_at,
        CASE
            WHEN temperature < min_temp OR temperature > max_temp THEN 'Temperature out of range'
            ELSE NULL
        END AS temperature_status,
        CASE
            WHEN soil_moisture < min_moisture OR soil_moisture > max_moisture THEN 'Moisture out of range'
            ELSE NULL
        END AS moisture_status
    FROM FilteredReadings
)
SELECT 
    plant_id,
    CASE
        WHEN SUM(CASE WHEN temperature_status IS NOT NULL THEN 1 ELSE 0 END) > 1 THEN 'Temperature out of range'
        ELSE 'Temperature within range'
    END AS temperature_status,
    CASE
        WHEN SUM(CASE WHEN moisture_status IS NOT NULL THEN 1 ELSE 0 END) > 1 THEN 'Moisture out of range'
        ELSE 'Moisture within range'
    END AS moisture_status,
    MAX(CASE 
            WHEN temperature_status IS NOT NULL OR moisture_status IS NOT NULL 
            THEN taken_at
            ELSE NULL
        END) AS last_out_of_range_time
FROM OutOfRangeReadings
GROUP BY plant_id
ORDER BY plant_id;
    """
    conn = make_engine()
    cursor = conn.cursor()

    cursor.execute(query)

    rows = cursor.fetchall()
    for row in rows:
        print(row)
    cursor.close()
    conn.close()


def insert_incidents():
    ...


if __name__ == "__main__":
    load_dotenv()
    get_data()
