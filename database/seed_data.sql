INSERT INTO beta.continent (continent_name)
VALUES 
    ('Europe'),
    ('Asia'),
    ('Africa'),
    ('North America'),
    ('South America'),
    ('Oceania');

INSERT INTO beta.country (country_name, continent_id)
VALUES 
    ('United States', (SELECT continent_id FROM beta.continent WHERE continent_name = 'North America')),
    ('Nigeria', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('Brazil', (SELECT continent_id FROM beta.continent WHERE continent_name = 'South America')),
    ('El Salvador', (SELECT continent_id FROM beta.continent WHERE continent_name = 'North America')),
    ('India', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Asia')),
    ('Canada', (SELECT continent_id FROM beta.continent WHERE continent_name = 'North America')),
    ('Ivory Coast', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('Germany', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Europe')),
    ('Croatia', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Europe')),
    ('Tunisia', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('Indonesia', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Asia')),
    ('Botswana', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('Spain', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Europe')),
    ('Japan', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Asia')),
    ('Sudan', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('Algeria', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('Ukraine', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Europe')),
    ('Libya', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('China', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Asia')),
    ('Chile', (SELECT continent_id FROM beta.continent WHERE continent_name = 'South America')),
    ('Tanzania', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('France', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Europe')),
    ('Bulgaria', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Europe')),
    ('Mexico', (SELECT continent_id FROM beta.continent WHERE continent_name = 'North America')),
    ('Malawi', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Africa')),
    ('Italy', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Europe')),
    ('Philippines', (SELECT continent_id FROM beta.continent WHERE continent_name = 'Asia'));


INSERT INTO beta.region (region_name, country_id)
VALUES 
    ('South Whittier', (SELECT country_id FROM beta.country WHERE country_name = 'United States')),
    ('Efon-Alaaye', (SELECT country_id FROM beta.country WHERE country_name = 'Nigeria')),
    ('Resplendor', (SELECT country_id FROM beta.country WHERE country_name = 'Brazil')),
    ('Ilopango', (SELECT country_id FROM beta.country WHERE country_name = 'El Salvador')),
    ('Jashpurnagar', (SELECT country_id FROM beta.country WHERE country_name = 'India')),
    ('Markham', (SELECT country_id FROM beta.country WHERE country_name = 'Canada')),
    ('Bonoua', (SELECT country_id FROM beta.country WHERE country_name = 'Ivory Coast')),
    ('Weimar', (SELECT country_id FROM beta.country WHERE country_name = 'Germany')),
    ('Kahului', (SELECT country_id FROM beta.country WHERE country_name = 'United States')),
    ('Longview', (SELECT country_id FROM beta.country WHERE country_name = 'United States')),
    ('Bensheim', (SELECT country_id FROM beta.country WHERE country_name = 'Germany')),
    ('Gainesville', (SELECT country_id FROM beta.country WHERE country_name = 'United States')),
    ('Yonkers', (SELECT country_id FROM beta.country WHERE country_name = 'United States')),
    ('Wangon', (SELECT country_id FROM beta.country WHERE country_name = 'Indonesia')),
    ('Tonota', (SELECT country_id FROM beta.country WHERE country_name = 'Botswana')),
    ('Reus', (SELECT country_id FROM beta.country WHERE country_name = 'Spain')),
    ('Carlos Barbosa', (SELECT country_id FROM beta.country WHERE country_name = 'Brazil')),
    ('Friedberg', (SELECT country_id FROM beta.country WHERE country_name = 'Germany')),
    ('Charlottenburg-Nord', (SELECT country_id FROM beta.country WHERE country_name = 'Germany')),
    ('Motomachi', (SELECT country_id FROM beta.country WHERE country_name = 'Japan')),
    ('Ar Ruseris', (SELECT country_id FROM beta.country WHERE country_name = 'Sudan')),
    ('El Achir', (SELECT country_id FROM beta.country WHERE country_name = 'Algeria')),
    ('Hlukhiv', (SELECT country_id FROM beta.country WHERE country_name = 'Ukraine')),
    ('Brunswick', (SELECT country_id FROM beta.country WHERE country_name = 'Germany')),
    ('Ueno-ebisumachi', (SELECT country_id FROM beta.country WHERE country_name = 'Japan')),
    ('Ajdabiya', (SELECT country_id FROM beta.country WHERE country_name = 'Libya')),
    ('Licheng', (SELECT country_id FROM beta.country WHERE country_name = 'China')),
    ('Gifhorn', (SELECT country_id FROM beta.country WHERE country_name = 'Germany')),
    ('Bachhraon', (SELECT country_id FROM beta.country WHERE country_name = 'India')),
    ('La Ligua', (SELECT country_id FROM beta.country WHERE country_name = 'Chile')),
    ('Dublin', (SELECT country_id FROM beta.country WHERE country_name = 'United States')),
    ('Malaut', (SELECT country_id FROM beta.country WHERE country_name = 'India')),
    ('Magomeni', (SELECT country_id FROM beta.country WHERE country_name = 'Tanzania')),
    ('Fujioka', (SELECT country_id FROM beta.country WHERE country_name = 'Japan')),
    ('Valence', (SELECT country_id FROM beta.country WHERE country_name = 'France')),
    ('Pujali', (SELECT country_id FROM beta.country WHERE country_name = 'India')),
    ('Smolyan', (SELECT country_id FROM beta.country WHERE country_name = 'Bulgaria')),
    ('Zacoalco de Torres', (SELECT country_id FROM beta.country WHERE country_name = 'Mexico')),
    ('Salima', (SELECT country_id FROM beta.country WHERE country_name = 'Malawi')),
    ('Catania', (SELECT country_id FROM beta.country WHERE country_name = 'Italy')),
    ('Calauan', (SELECT country_id FROM beta.country WHERE country_name = 'Philippines')),
    ('Acayucan', (SELECT country_id FROM beta.country WHERE country_name = 'Mexico')),
    ('Split', (SELECT country_id FROM beta.country WHERE country_name = 'Croatia')),
    ('Siliana', (SELECT country_id FROM beta.country WHERE country_name = 'Tunisia')),
    ('Oschatz', (SELECT country_id FROM beta.country WHERE country_name = 'Germany'))
    ;

INSERT INTO beta.botanist (first_name, last_name, phone, email)
VALUES  
    ('Gertrude', 'Jekyll', '001-481-273-3691x127', 'gertrude.jekyll@lnhm.co.uk'),  
    ('Carl', 'Linnaeus', '(146)994-1635x35992', 'carl.linnaeus@lnhm.co.uk'),  
    ('Eliza', 'Andrews', '(846)669-6651x75948', 'eliza.andrews@lnhm.co.uk');

INSERT INTO beta.plant (plant_id, plant_name, plant_scientific_name, region_id, botanist_id)
VALUES
    (1, 'Venus flytrap', 'Dionaea muscipula', (SELECT region_id FROM beta.region WHERE region_name = 'South Whittier'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (2, 'Corpse flower', 'Amorphophallus titanum', (SELECT region_id FROM beta.region WHERE region_name = 'Efon-Alaaye'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (3, 'Rafflesia arnoldii', 'Rafflesia arnoldii', (SELECT region_id FROM beta.region WHERE region_name = 'Resplendor'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (4, 'Black bat flower', 'Tacca palmata', (SELECT region_id FROM beta.region WHERE region_name = 'Ilopango'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (5, 'Pitcher plant', 'Sarracenia catesbaei', (SELECT region_id FROM beta.region WHERE region_name = 'Jashpurnagar'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (6, 'Wollemi pine', 'Wollemia nobilis', (SELECT region_id FROM beta.region WHERE region_name = 'Markham'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (8, 'Bird of paradise', 'Heliconia schiedeana Fire and Ice', (SELECT region_id FROM beta.region WHERE region_name = 'Bonoua'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (9, 'Cactus', 'Pereskia grandifolia', (SELECT region_id FROM beta.region WHERE region_name = 'Weimar'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (10, 'Dragon tree', 'Dracaena draco', (SELECT region_id FROM beta.region WHERE region_name = 'Split'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (11, 'Asclepias curassavica', 'Asclepias curassavica', (SELECT region_id FROM beta.region WHERE region_name = 'Kahului'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (12, 'Angel’s trumpet', 'Brugmansia x candida', (SELECT region_id FROM beta.region WHERE region_name = 'Longview'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (13, 'Canna lily', 'Canna indica', (SELECT region_id FROM beta.region WHERE region_name = 'Bensheim'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (14, 'Taro', 'Colocasia esculenta', (SELECT region_id FROM beta.region WHERE region_name = 'Gainesville'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (15, 'Cuphea', 'Cuphea', (SELECT region_id FROM beta.region WHERE region_name = 'Siliana'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (16, 'Euphorbia', 'Euphorbia cotinifolia', (SELECT region_id FROM beta.region WHERE region_name = 'Yonkers'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (17, 'Sweet potato', 'Ipomoea batatas', (SELECT region_id FROM beta.region WHERE region_name = 'Wangon'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (18, 'Sweet potato', 'Ipomoea batatas', (SELECT region_id FROM beta.region WHERE region_name = 'Oschatz'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (19, 'Banana plant', 'Musa basjoo', (SELECT region_id FROM beta.region WHERE region_name = 'Tonota'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (20, 'Salvia', 'Salvia splendens', (SELECT region_id FROM beta.region WHERE region_name = 'Reus'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (21, 'Anthurium', 'Anthurium andraeanum', (SELECT region_id FROM beta.region WHERE region_name = 'Carlos Barbosa'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (22, 'Bird of paradise', 'Heliconia schiedeana Fire and Ice', (SELECT region_id FROM beta.region WHERE region_name = 'Friedberg'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (23, 'Cordyline', 'Cordyline fruticosa', (SELECT region_id FROM beta.region WHERE region_name = 'Charlottenburg-Nord'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (24, 'Ficus', 'Ficus carica', (SELECT region_id FROM beta.region WHERE region_name = 'Motomachi'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (25, 'Palm trees', 'Arecaceae', (SELECT region_id FROM beta.region WHERE region_name = 'Ar Ruseris'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (26, 'Dieffenbachia', 'Dieffenbachia seguine', (SELECT region_id FROM beta.region WHERE region_name = 'El Achir'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (27, 'Spathiphyllum', 'Spathiphyllum', (SELECT region_id FROM beta.region WHERE region_name = 'Hlukhiv'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (28, 'Croton', 'Codiaeum variegatum', (SELECT region_id FROM beta.region WHERE region_name = 'Brunswick'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (29, 'Aloe vera', 'Aloe vera', (SELECT region_id FROM beta.region WHERE region_name = 'Ueno-ebisumachi'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (30, 'Ficus elastica', 'Ficus elastica', (SELECT region_id FROM beta.region WHERE region_name = 'Ajdabiya'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (31, 'Sansevieria', 'Sansevieria trifasciata', (SELECT region_id FROM beta.region WHERE region_name = 'Licheng'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (32, 'Philodendron', 'Philodendron hederaceum', (SELECT region_id FROM beta.region WHERE region_name = 'Gifhorn'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (33, 'Schefflera', 'Schefflera arboricola', (SELECT region_id FROM beta.region WHERE region_name = 'Bachhraon'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (34, 'Aglaonema', 'Aglaonema commutatum', (SELECT region_id FROM beta.region WHERE region_name = 'Reus'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (35, 'Monstera', 'Monstera deliciosa', (SELECT region_id FROM beta.region WHERE region_name = 'La Ligua'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (36, 'Tacca', 'Tacca integrifolia', (SELECT region_id FROM beta.region WHERE region_name = 'Dublin'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (37, 'Psychopsis', 'Psychopsis papilio', (SELECT region_id FROM beta.region WHERE region_name = 'Malaut'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (38, 'Saintpaulia', 'Saintpaulia ionantha', (SELECT region_id FROM beta.region WHERE region_name = 'Magomeni'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (39, 'Gaillardia', 'Gaillardia aestivalis', (SELECT region_id FROM beta.region WHERE region_name = 'Fujioka'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (40, 'Amaryllis', 'Hippeastrum', (SELECT region_id FROM beta.region WHERE region_name = 'Valence'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (41, 'Caladium', 'Caladium bicolor', (SELECT region_id FROM beta.region WHERE region_name = 'Pujali'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (42, 'Chlorophytum', 'Chlorophytum comosum', (SELECT region_id FROM beta.region WHERE region_name = 'Smolyan'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (44, 'Araucaria', 'Araucaria heterophylla', (SELECT region_id FROM beta.region WHERE region_name = 'Zacoalco de Torres'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (45, 'Begonia', 'Begonia Art Hodes', (SELECT region_id FROM beta.region WHERE region_name = 'South Whittier'), (SELECT botanist_id FROM beta.botanist WHERE email = 'gertrude.jekyll@lnhm.co.uk')),
    (46, 'Medinilla', 'Medinilla magnifica', (SELECT region_id FROM beta.region WHERE region_name = 'Salima'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (47, 'Calliandra', 'Calliandra haematocephala', (SELECT region_id FROM beta.region WHERE region_name = 'Catania'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (48, 'Zamioculcas', 'Zamioculcas zamiifolia', (SELECT region_id FROM beta.region WHERE region_name = 'Calauan'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk')),
    (49, 'Crassula', 'Crassula ovata', (SELECT region_id FROM beta.region WHERE region_name = 'Acayucan'), (SELECT botanist_id FROM beta.botanist WHERE email = 'eliza.andrews@lnhm.co.uk')),
    (50, 'Epipremnum', 'Epipremnum aureum', (SELECT region_id FROM beta.region WHERE region_name = 'Resplendor'), (SELECT botanist_id FROM beta.botanist WHERE email = 'carl.linnaeus@lnhm.co.uk'));




UPDATE beta.plant
SET
    min_temp = 15.0,
    max_temp = 30.0,
    min_moisture = 40,
    max_moisture = 60;


UPDATE beta.plant
SET botanist_id = (
    SELECT botanist_id
    FROM beta.botanist
    WHERE email = 'botanist_email@example.com'
)
WHERE plant_id = @plant_id;

   