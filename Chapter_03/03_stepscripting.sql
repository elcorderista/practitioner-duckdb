-- 1. Eliminamos las tablas y vistas si existen
DROP VIEW IF EXISTS web_log_view;
DROP TABLE IF EXISTS web_log_split;
DROP TABLE IF EXISTS language_iso;
DROP TABLE IF EXISTS web_log_text;

-- 2. Creamos la tabla raw a partir del log
CREATE OR REPLACE TABLE web_log_text (raw_text VARCHAR);

-- 3. Copiamos el log a la tabla raw
COPY web_log_text 
FROM 'data/data_03/access.log' (delimiter '', header false);

-- 4. Creamos la tabla split a partir de la tabla raw
CREATE OR REPLACE TABLE web_log_split
AS
SELECT regexp_extract(raw_text, '^[0-9\.]*' ) as client_ip, 
  regexp_extract(raw_text, '\[(.*)\]',1 ) as http_date_text,
  regexp_extract(raw_text, '"([A-Z]*) ',1 ) as http_method,
  regexp_extract(raw_text, '([a-zA-Z\-]*)"$', 1) as http_lang
FROM  web_log_text;

-- 5. Creamos la tabla de idiomas 
CREATE OR REPLACE TABLE language_iso(
  lang_iso VARCHAR PRIMARY KEY, 
  language_name VARCHAR);

-- 6. Creamos la tabla de idiomas a partir del archivo CSV
INSERT INTO language_iso
SELECT *
FROM read_csv('data/data_02/language_iso.csv', AUTO_DETECT=TRUE, header=True);

-- 7. Creamos la vista a partir de la tabla split y la tabla de idiomas
CREATE OR REPLACE VIEW web_log_view
AS
SELECT wls.client_ip,
strptime(wls.http_date_text, '%d/%b/%Y:%H:%M:%S %z') as http_date,
wls.http_method,
wls.http_lang,
lang.language_name 
FROM web_log_split wls
LEFT OUTER JOIN language_iso lang on (wls.http_lang = lang.lang_iso);

-- 8. Mostramos resultados
SELECT *
FROM web_log_view
LIMIT 5;