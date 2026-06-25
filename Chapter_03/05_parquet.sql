-- Los datos se extraen del sitio https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
-- Leeremos archivos parquet. 
-- 1. Creamos la tabla trip de los viajes 
CREATE OR REPLACE TABLE trips AS 
SELECT * 
FROM read_parquet('https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_2026-01.parquet');


-- 2. Conteo de datos 
SELECT COUNT(*) AS total_trips
FROM trips;

SELECT tpep_pickup_datetime, -- fecha y hora de inicio de viaje
    trip_distance, -- distancia del viaje en millas
    fare_amount, -- tarifa del taxi en dólares. 
    tip_amount, -- propina en dólares 
    PULocationID, -- identificador numérico del lugar de recogida 
    DOLocationID -- identificador numerico del lugar de destino 
FROM trips
LIMIT 10;

-- 3. Creamos la tabla de ubicaciones de recogida y destino
CREATE OR REPLACE TABLE locations (
    LocationID int PRIMARY KEY,
    Borough varchar,
    Zone varchar,
    service_zone varchar
);

-- 4. Descargamos el file de zonas para cargarlo en la tabla 
INSERT INTO locations(LocationID, Borough, Zone, service_zone)
SELECT LocationID, Borough, Zone, service_zone
FROM read_csv('https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv');

-- 5. Validamos que los datos se cargaron de forma correcta
SELECT LocationID, Borough, Zone
FROM locations
LIMIT 10;

-- 6. Creamos la relación de ubicaciones 
CREATE OR REPLACE TABLE trips_with_locations AS 
SELECT t.*, 
    l_pu.zone AS pickup_up_zone, -- nueva columna zona de recogida
    l_do.zone AS drop_off_zone -- nueva columna zona de destino
FROM trips AS t 
LEFT JOIN locations AS l_pu 
    ON l_pu.LocationID = t.PULocationID
LEFT JOIN locations AS l_do
    ON l_do.LocationID = t.DOLocationID;

-- 7. Validamos la relación 
SELECT tpep_pickup_datetime, 
    pickup_up_zone,
    drop_off_zone,
    trip_distance,
FROM trips_with_locations
LIMIT 10;