-- 1. Hacemos un query a un sitio remoto
SELECT count(*)
from read_csv_auto('https://raw.githubusercontent.com/migumax/tennis_atp/refs/heads/master/2023.csv');


-- 2. Validamos la salida en line
-- 2.1 cambiamos el mode a line y solimitamos una linea del query anteior
select *
from read_csv_auto('https://raw.githubusercontent.com/migumax/tennis_atp/refs/heads/master/2023.csv')
limit 1;

-- 3. Complex Query
-- Por cada combinación única de país del ganador, país perdedor, mano hábil del gandor y mano hábil del perdedor
-- necesitamos calcular:
-- a. El numero de tornos distintos en los que ha ocurrido esa combinación
-- b. La edad media de los ganadores 
-- c. La edad maxima de los perdedores 
-- d. Agrupoa los resultados por todas las columnas que no sean agregaciones 
select 
    winner_ioc,
    loser_ioc,
    winner_hand,
    loser_hand,
    count(DISTINCT(tourney_id)) as num_winners, -- total de unicidad por juego
    avg(winner_age) as avg_winner_age, 
    max(loser_age) as max_loser_age,
    from read_csv_auto("https://raw.githubusercontent.com/migumax/tennis_atp/refs/heads/master/2023.csv")
    GROUP BY all;