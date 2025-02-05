
DROP TABLE IF EXISTS beta.botanist;
DROP TABLE IF EXISTS beta.plant;
DROP TABLE IF EXISTS beta.recording;
DROP TABLE IF EXISTS beta.continent;
DROP TABLE IF EXISTS beta.region;
DROP TABLE IF EXISTS beta.plant_images;
DROP TABLE IF EXISTS beta.incident;
DROP TABLE IF EXISTS beta.country;


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
    region_id SMALLINT NOT NULL,
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

CREATE TABLE beta.region(
    region_id SMALLINT IDENTITY(1,1) NOT NULL,
    region_name VARCHAR(30) NOT NULL,
    country_id SMALLINT NOT NULL
);
ALTER TABLE
    beta.region ADD CONSTRAINT region_id_primary PRIMARY KEY(region_id);

CREATE TABLE beta.plant_images(
    plant_image_id SMALLINT IDENTITY(1,1) NOT NULL,
    plant_id SMALLINT NOT NULL,
    image_url VARCHAR(255) NOT NULL,
    license SMALLINT
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
    beta.incident ADD CONSTRAINT incident_plant_id_foreign FOREIGN KEY(plant_id) REFERENCES beta.plant(plant_id);
ALTER TABLE
    beta.plant ADD CONSTRAINT plant_region_id_foreign FOREIGN KEY(region_id) REFERENCES beta.region(region_id);
ALTER TABLE
    beta.plant_images ADD CONSTRAINT plant_images_plant_id_foreign FOREIGN KEY(plant_id) REFERENCES beta.plant(plant_id);
ALTER TABLE
    beta.region ADD CONSTRAINT region_country_id_foreign FOREIGN KEY(country_id) REFERENCES beta.country(country_id);



