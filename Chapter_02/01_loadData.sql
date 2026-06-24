-- Carga de un file separados por comas 

CREATE OR REPLACE TABLE foods (
    food_name VARCHAR PRIMARY KEY,
    color VARCHAR,
    calories INT,
    is_healthy BOOLEAN
);

COPY foods FROM ('./data/data_02/foods_no_heading.csv');

SELECT * FROM foods;


