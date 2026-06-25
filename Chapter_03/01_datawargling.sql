-- 1. Creacion de tabla raw para limipieza de datos
CREATE OR REPLACE TABLE web_log_text (raw_text VARCHAR);

-- 2. Copiamos de un archivo log a la base usa como delimitador el espacio 
-- Al especificar vacíon el delim indica que tome cada línea como una fila 
-- Importante delim '' para indicar que hay saldo de linea. 
-- HEADER false para evitar que se coma la primera linea. 
COPY web_log_text FROM 'data/data_03/access.log' (DELIM '', HEADER false);

-- 3. Validamos los datos
SELECT * 
FROM web_log_text
LIMIT 10;

-- 4. Extraemos los IPS del log 
SELECT 
    REGEXP_EXTRACT(raw_text, '^[0-9\.]*') AS client_ip
FROM web_log_text
LIMIT 5; 

-- 5. Extraemos los demas puntos del correo 
-- Se indica el grupo de captura, en este caso el primero 1, que encuentre. 
SELECT REGEXP_EXTRACT(raw_text, '^[0-9\.]*') AS client_ip,
    REGEXP_EXTRACT(raw_text, '\[(.*)\]', 1) AS date_text,
    REGEXP_EXTRACT(raw_text, '"([A-Z]*) ', 1 ) AS http_method,
    REGEXP_EXTRACT(raw_text, '([a-zA-Z\-]*)"$', 1) AS lang
FROM web_log_text
LIMIT 5;

-- 6. Una vez validado el split creamos insertamos en una tabla. 
CREATE OR REPLACE TABLE web_log_split AS 
SELECT REGEXP_EXTRACT(raw_text, '^[0-9\.]*') AS client_ip,
    REGEXP_EXTRACT(raw_text, '\[(.*)\]', 1) AS date_text,
    REGEXP_EXTRACT(raw_text, '"([A-Z]*) ', 1 ) AS http_method,
    REGEXP_EXTRACT(raw_text, '([a-zA-Z\-]*)"$', 1) AS http_lang
FROM web_log_text;

-- 7. Valildamsos la conversión de cadena a timestamp 
-- %z responde a la subcadena +0330, que es el desfase del horario 
-- tres horas y treinta minutos con respecto a UTC (Coordinated Universal Time)
SELECT client_ip, strptime(
    date_text, '%d/%b/%Y:%H:%M:%S %z' 
) AS http_date, http_method, http_lang
FROM web_log_split;

-- 8. Alteramos la tabla agregando la columna timestamp 
ALTER TABLE web_log_split ADD COLUMN http_date 
TIMESTAMP WITH TIME ZONE;

-- 8.1 Aplicamos la conversion de la columna date
UPDATE web_log_split
SET http_date = strptime(
    date_text, '%d/%b/%Y:%H:%M:%S %z'
);

-- 8.2 Validamos 
SELECT client_ip, 
    http_date,
    http_method, 
    http_lang
FROM web_log_split;

-- 9. Creamos una tabla de códigos de idiomas descriptivos 
-- para asignar códigos de dos letras ISO 639-1
CREATE OR REPLACE TABLE language_iso (
    lang_iso VARCHAR PRIMARY KEY,
    language_name VARCHAR
);

-- 10. Cargamos los datos del file csv
INSERT INTO language_iso
SELECT * 
FROM read_csv('data/data_02/language_iso.csv');

-- 11. Hacemos un join con language para obtener nombres descriptivos
SELECT wls.http_date, wls.http_lang, 
    lang.language_name
FROM web_log_split AS wls
LEFT JOIN language_iso AS lang
    ON (wls.http_lang = lang.lang_iso);
