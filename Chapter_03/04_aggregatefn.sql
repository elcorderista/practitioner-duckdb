-- 1. Obtener:
-- El valor mas nuevo y viejo de fechas del log 
-- Contar el el numero de registros capturados 
SELECT min(http_date) AS date_earliest,
    max(http_date) AS date_latest,
    count(*) AS web_log_count
FROM web_log_view;    

-- 2. Extraer solo el día del timestamp
SELECT http_date,
    time_bucket(interval '1 day', http_date) AS day
FROM web_log_view;

-- 3. Queremos agrupar todas las filas que comparten el mismo día e idioma en una sola fila 
-- y contar el número de registros de cada grupo. Y ordernar los resultados de cada grupo 
-- en orden descendente por día y por conteo de registros.
-- a. Crea un subconsulta con el día y el idioma 
-- b. Le pedimos que tome por dia - lenguaje y los cuente (Idiomas en todo el día)
-- c. Muestramelos ordenados por dia y su conteo descendente por día.
WITH web_cte AS (
    SELECT client_ip,
        time_bucket(interval '1 day', http_date) AS day,
        language_name
    FROM web_log_view
)
SELECT day, language_name, count(*) AS count 
FROM web_cte
GROUP BY day, language_name
ORDER BY day ASC, count(*) DESC;

WITH web_cte AS (
    SELECT client_ip,
        time_bucket(interval '1 day', http_date) AS day,
        language_name
    FROM web_log_view
)
SELECT day, language_name, count(*) AS count 
FROM web_cte
GROUP BY day, language_name
ORDER BY day DESC, count(*) DESC;

-- 4. Queremos por idioma por dia tuvimos de visitas
WITH web_cte AS (
    SELECT time_bucket(interval '1 day', http_date) AS day,
    language_name
    FROM web_log_view
)
PIVOT web_cte 
ON language_name 
USING count(*);

-- 5. Analizamos por dia y por idioma cuantas visitas tuvimos 
-- por día, ordenando por el primer dia registrado. 
WITH web_cte AS (
    SELECT time_bucket(interval '1 day', http_date) AS day,
           language_name
    FROM web_log_view
)
PIVOT web_cte
ON language_name
USING count(*)
GROUP BY day
ORDER BY day ASC;