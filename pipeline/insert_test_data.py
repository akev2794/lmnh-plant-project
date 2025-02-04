import pandas as pd
import json

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
        city = plant['origin_location'][4].split("/")[1]
        scientific_name = ', '.join(
            plant['scientific_name']) if 'scientific_name' in plant and plant['scientific_name'] else None
        soil_moisture = plant['soil_moisture']
        temperature = plant['temperature']

        record = {
            "email": email,
            "first_name": first_name,
            "last_name": last_name,
            "phone": phone,
            "license": license,
            "last_watered": last_watered,
            "plant_name": plant_name,
            "town": town,
            "country": country,
            "continent": continent,
            "city": city,
            "plant_scientific_name": scientific_name,
            "soil_moisture": soil_moisture,
            "temperature": temperature
        }

        records.append(record)

df = pd.DataFrame(records)

print(df)
