DROP TABLE IF EXISTS beta.botanist;
DROP TABLE IF EXISTS beta.plant_images;
DROP TABLE IF EXISTS beta.town;
DROP TABLE IF EXISTS beta.plant;
DROP TABLE IF EXISTS beta.incident;
DROP TABLE IF EXISTS beta.recording;
DROP TABLE IF EXISTS beta.city;
DROP TABLE IF EXISTS beta.country;
DROP TABLE IF EXISTS beta.continent;


CREATE TABLE beta.botanist (
    botanist_id SMALLINT IDENTITY(1,1) NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(255) NOT NULL,
);
ALTER TABLE
    beta.botanist ADD CONSTRAINT botanist_id_primary PRIMARY KEY(botanist_id);

CREATE TABLE beta.plant(
    plant_id SMALLINT NOT NULL,
    plant_name VARCHAR(255) NOT NULL,
    last_watered TIMESTAMP,
    town_id SMALLINT NOT NULL,
    plant_scientific_name VARCHAR(75)
);
ALTER TABLE
    beta.plant ADD CONSTRAINT plant_id_primary PRIMARY KEY(plant_id);

CREATE TABLE beta.recording(
    recording_id INT IDENTITY(1,1) NOT NULL,
    plant_id SMALLINT NOT NULL,
    soil_moisture FLOAT(53) NOT NULL,
    temperature FLOAT(53) NOT NULL,
    taken_at TIMESTAMP NOT NULL
);
ALTER TABLE
    beta.recording ADD CONSTRAINT recording_id_primary PRIMARY KEY(recording_id);
    
CREATE TABLE beta.continent(
    continent_id SMALLINT IDENTITY(1,1) NOT NULL,
    continent_name VARCHAR(30) NOT NULL
);
ALTER TABLE
    beta.continent ADD CONSTRAINT continent_id_primary PRIMARY KEY(continent_id);

CREATE TABLE beta.country(
    country_id SMALLINT IDENTITY(1,1) NOT NULL,
    country_name VARCHAR(50) NOT NULL,
    continent_id SMALLINT NOT NULL
);
ALTER TABLE
    beta.country ADD CONSTRAINT country_id_primary PRIMARY KEY(country_id);

CREATE TABLE beta.city(
    city_id SMALLINT IDENTITY(1,1) NOT NULL,
    city_name VARCHAR(30) NOT NULL,
    country_id SMALLINT NOT NULL
);
ALTER TABLE
    beta.city ADD CONSTRAINT city_id_primary PRIMARY KEY(city_id);

CREATE TABLE beta.town(
    town_id SMALLINT IDENTITY(1,1) NOT NULL,
    town_name VARCHAR(30) NOT NULL,
    city_id SMALLINT NOT NULL
);
ALTER TABLE
    beta.town ADD CONSTRAINT town_id_primary PRIMARY KEY(town_id);

CREATE TABLE beta.plant_images(
    plant_image_id SMALLINT IDENTITY(1,1) NOT NULL,
    plant_id SMALLINT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    license SMALLINT NOT NULL
);
ALTER TABLE
    beta.plant_images ADD CONSTRAINT plant_image_id_primary PRIMARY KEY(plant_image_id);

CREATE TABLE beta.incident(
    incident_id SMALLINT IDENTITY(1,1) NOT NULL,
    plant_id SMALLINT NOT NULL,
    incident_type VARCHAR(11),
    incident_at TIMESTAMP NOT NULL
);
ALTER TABLE
    beta.incident ADD CONSTRAINT incident_incident_id_primary PRIMARY KEY(incident_id);


ALTER TABLE
    beta.recording ADD CONSTRAINT recording_plant_id_foreign FOREIGN KEY(plant_id) REFERENCES beta.plant(plant_id);
ALTER TABLE
    beta.country ADD CONSTRAINT country_continent_id_foreign FOREIGN KEY(continent_id) REFERENCES beta.continent(continent_id);
ALTER TABLE
    beta.city ADD CONSTRAINT city_country_id_foreign FOREIGN KEY(country_id) REFERENCES beta.country(country_id);
ALTER TABLE
    beta.incident ADD CONSTRAINT incident_plant_id_foreign FOREIGN KEY(plant_id) REFERENCES beta.plant(plant_id);
ALTER TABLE
    beta.plant ADD CONSTRAINT plant_town_id_foreign FOREIGN KEY(town_id) REFERENCES beta.town(town_id);
ALTER TABLE
    beta.plant_images ADD CONSTRAINT plant_images_plant_id_foreign FOREIGN KEY(plant_id) REFERENCES beta.plant(plant_id);
ALTER TABLE
    beta.town ADD CONSTRAINT town_city_id_foreign FOREIGN KEY(city_id) REFERENCES beta.city(city_id);



