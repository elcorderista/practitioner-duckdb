-- 1. Creamos la vista sobre la taabla web_log_split
CREATE OR REPLACE VIEW web_log_view AS 
SELECT wls.client_ip,
    strptime(
        wls.date_text, 
        '%d/%b/%Y:%H:%M:%S %z'
    ) AS http_date, 
    wls.http_method,
    wls.http_lang,
    lang.language_name
    FROM web_log_split AS wls
    LEFT JOIN language_iso AS lang
    ON (wls.http_lang = lang.lang_iso);

-- 2. Describir la vista que acabamos de crear 
DESCRIBE web_log_view;

-- 3. Testing the view. 
SELECT * 
FROM web_log_view
LIMIT 5;