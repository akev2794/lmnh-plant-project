CREATE TABLE "botanist"(
    "botanist_id" SMALLINT NOT NULL,
    "first_name" VARCHAR(30) NOT NULL,
    "last_name" VARCHAR(30) NOT NULL,
    "phone" VARCHAR(30) NOT NULL,
    "email" VARCHAR(255) NOT NULL,
);
ALTER TABLE
    "botanist" ADD CONSTRAINT "botanist_id_primary" PRIMARY KEY("botanist_id");

CREATE TABLE "plant"(
    "plant_id" SMALLINT NOT NULL,
    "plant_name" VARCHAR(255) NOT NULL,
    "last_watered" TIMESTAMP,
    "town_id" SMALLINT NOT NULL,
    "plant_scientific_name" VARCHAR(75)
);
ALTER TABLE
    "plant" ADD CONSTRAINT "plant_id_primary" PRIMARY KEY("plant_id");

CREATE TABLE "recording"(
    "recording_id" INT NOT NULL,
    "plant_id" SMALLINT NOT NULL,
    "soil_moisture" FLOAT(53) NOT NULL,
    "temperature" FLOAT(53) NOT NULL,
    "taken_at" TIMESTAMP NOT NULL
);
ALTER TABLE
    "recording" ADD CONSTRAINT "recording_id_primary" PRIMARY KEY("recording_id");
    
CREATE TABLE "continent"(
    "continent_id" SMALLINT NOT NULL,
    "continent_name" VARCHAR(30) NOT NULL
);
ALTER TABLE
    "continent" ADD CONSTRAINT "continent_id_primary" PRIMARY KEY("continent_id");

CREATE TABLE "country"(
    "country_id" SMALLINT NOT NULL,
    "country_name" VARCHAR(50) NOT NULL,
    "continent_id" SMALLINT NOT NULL
);
ALTER TABLE
    "country" ADD CONSTRAINT "country_id_primary" PRIMARY KEY("country_id");

CREATE TABLE "city"(
    "city_id" SMALLINT NOT NULL,
    "cityname" VARCHAR(30) NOT NULL,
    "country_id" SMALLINT NOT NULL
);
ALTER TABLE
    "city" ADD CONSTRAINT "city_id_primary" PRIMARY KEY("city_id");

CREATE TABLE "town"(
    "town_id" SMALLINT NOT NULL,
    "town_name" VARCHAR(30) NOT NULL,
    "city_id" SMALLINT NOT NULL
);
ALTER TABLE
    "town" ADD CONSTRAINT "town_id_primary" PRIMARY KEY("town_id");

CREATE TABLE "plant_botanist_assignment"(
    "assignment_id" SMALLINT NOT NULL,
    "plant_id" SMALLINT NOT NULL,
    "botanist_id" SMALLINT NOT NULL
);
ALTER TABLE
    "plant_botanist_assignment" ADD CONSTRAINT "plant_botanist_assignment_id_primary" PRIMARY KEY("assignment_id");

CREATE TABLE "plant_images"(
    "plant_image_id" SMALLINT NOT NULL,
    "plant_id" SMALLINT NOT NULL,
    "license" SMALLINT NOT NULL
);
ALTER TABLE
    "plant_images" ADD CONSTRAINT "plant_image_id_primary" PRIMARY KEY("plant_image_id");

CREATE TABLE "incident"(
    "incident_id" SMALLINT NOT NULL,
    "plant_id" SMALLINT NOT NULL,
    "incident_type" VARCHAR(11),
    "incident_at" TIMESTAMP NOT NULL
);
ALTER TABLE
    "incident" ADD CONSTRAINT "incident_incident_id_primary" PRIMARY KEY("incident_id");


ALTER TABLE
    "recording" ADD CONSTRAINT "recording_plant_id_foreign" FOREIGN KEY("plant_id") REFERENCES "plant"("plant_id");
ALTER TABLE
    "country" ADD CONSTRAINT "country_continent_id_foreign" FOREIGN KEY("continent_id") REFERENCES "continent"("continent_id");
ALTER TABLE
    "city" ADD CONSTRAINT "city_country_id_foreign" FOREIGN KEY("country_id") REFERENCES "country"("country_id");
ALTER TABLE
    "incident" ADD CONSTRAINT "incident_plant_id_foreign" FOREIGN KEY("plant_id") REFERENCES "plant"("plant_id");
ALTER TABLE
    "plant" ADD CONSTRAINT "plant_town_id_foreign" FOREIGN KEY("town_id") REFERENCES "town"("town_id");
ALTER TABLE
    "plant_images" ADD CONSTRAINT "plant_images_plant_id_foreign" FOREIGN KEY("plant_id") REFERENCES "plant"("plant_id");
ALTER TABLE
    "plant_botanist_assignment" ADD CONSTRAINT "plant_botanist_assignment_botanist_id_foreign" FOREIGN KEY("botanist_id") REFERENCES "botanist"("botanist_id");
ALTER TABLE
    "town" ADD CONSTRAINT "town_city_id_foreign" FOREIGN KEY("city_id") REFERENCES "city"("city_id");
ALTER TABLE
    "plant_botanist_assignment" ADD CONSTRAINT "plant_botanist_assignment_plant_id_foreign" FOREIGN KEY("plant_id") REFERENCES "plant"("plant_id");
