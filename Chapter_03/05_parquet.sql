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
    trip_distance
FROM trips_with_locations
LIMIT 10;

-- 8 Análisis de datos. 
-- Analizar la tarifa  minima, maxima y promedio 
-- Analizar el promedio de propinas solo con pago en tarjeta 
-- a. Con time_bucket agrupamos por dia 
-- b. Obtenemos el numero de viajes
-- c. Obtenemos las tarifas min, max y promedio y promedio de propinas 
-- d. usamos un case para el type 1 que es tarjeta para calcular el promedio de propinas 
SELECT time_bucket('1 day', tpep_pickup_datetime) AS day,
    count(*) AS total_trips,
    min(fare_amount) AS min_fare,
    max(fare_amount) AS max_fare,
    avg(fare_amount) AS avg_fare,
    avg(
        CASE 
            WHEN payment_type = 1 
            THEN tip_amount/fare_amount 
            END
    ) * 100 AS cc_tip_avg_percentage
    FROM trips_with_locations
    WHERE tpep_pickup_datetime between '2026-01-01 00:00:00' and '2026-01-30 23:59:59'
    AND fare_amount > 0
    GROUP BY 1,
    order by 1;
 

 select min(tpep_pickup_datetime), max(tpep_pickup_datetime)
 from trips_with_locations;

 -- 9. Usaremos Window Functions para: Determinar el monto maximo por dia
 -- a. Usaremos una CTE para obtner el top del dia 
 -- b. Sobre este grupo, calcularemos con una Windows Function el maximo de la tarifa. 
 -- c. Seria tomar cuando fate_date sea igual a max_day_fare
WITH cte AS (
    SELECT twl.*, 
    max(fare_amount) OVER (
        PARTITION BY 
            time_bucket('1 day', tpep_pickup_datetime)
     ) AS max_day_fate_amount
     FROM trips_with_locations as twl 
)
SELECT tpep_pickup_datetime, tpep_dropoff_datetime , pickup_up_zone, drop_off_zone, fare_amount 
FROM cte
WHERE fare_amount = max_day_fate_amount
 AND tpep_pickup_datetime BETWEEN '2026-01-01 00:00:00' and '2026-01-30 23:59:59'
 ORDER BY tpep_pickup_datetime;
