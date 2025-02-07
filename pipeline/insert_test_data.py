# pylint: skip-file
"""Reads tests data json and inserts it into the database
to allow someone to work on the dashboard with data while the pipeline is being built"""

import pandas as pd
import json
import pyodbc
from dotenv import environ as ENV


def get_connection():
    """Makes and returns a pymysql connection to the MySQL RDS database."""
    connection = pymysql.connect(host=ENV['DB_HOST'],
                                 user=ENV['DB_USER'],
                                 password=ENV['DB_PASSWORD'],
                                 database=ENV['DB_NAME'],
                                 charset='utf8mb4',
                                 cursorclass=pymysql.cursors.DictCursor)
    return connection


with open("plant_data.json", "r") as file:
    data = json.load(file)

records = []

for plant in data:
    if 'error' not in plant:
        botanist = plant['botanist']
        name_split = botanist['name'].split(" ")

        email = botanist['email']
        first_name = name_split[0]
        last_name = name_split[1] if len(name_split) > 1 else ""
        phone = botanist['phone']
        if 'images' in plant and plant['images'] is not None:
            if 'license' in plant['images']:
                license = plant['images']['license']
            else:
                license = None
        else:
            license = None
        last_watered = plant['last_watered']
        plant_name = plant['name']
        town = plant['origin_location'][2]
        country = plant['origin_location'][3]
        continent = plant['origin_location'][4]
        scientific_name = ', '.join(
            plant['scientific_name']) if 'scientific_name' in plant and plant['scientific_name'] else None
        soil_moisture = plant['soil_moisture']
        temperature = plant['temperature']
        time = plant['recording_taken']

        record = {
            "license": license,
            "last_watered": last_watered,
            "plant_name": plant_name,
            "town": town,
            "country": country,
            "continent": continent,
            "plant_scientific_name": scientific_name,
            "soil_moisture": soil_moisture,
            "temperature": temperature,
            "time": time
        }

        records.append(record)

df = pd.DataFrame(records)

print(df)
