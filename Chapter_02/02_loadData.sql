-- CARGA DE ARCHIVOS CON TABS Y HEADER
-- Se agregan datos a una tabla existente
-- Las rutas estan configuradas corriendo desde el path del proyecto con duckdb. 
-- Mas detalle sobre los parámetros de COPY en la documentación oficial: https://duckdb.org/docs/current/data/csv/overview
COPY foods (food_name, is_healthy, color, calories)
FROM './data/data_02/foods_with_heading.tsv' (DELIM '\t', HEADER true);

SELECT * FROM foods;