
```yaml
date: June 15-2026
book: Getting Started with DuckDB by Simon Aubury & Ned Letcher
```

# Instalación

**Official Installation CLI**
- `https://duckdb.org/install/?platform=macos&environment=cli`

**Oficial Repo Python**
- `https://github.com/duckdb/duckdb-python`


**Instalación**
```bash
curl https://install.duckdb.org | sh
```

# Comandos

```bash 
# Validar la versión instalada
duckdb --version
```
## Comandos CLI
```bash
# Muestra todas las tablas de la base actual 
.tables

# Mostrar el schema de creación de una tabla
.schema <tableName> 

# Modos de salida (column, markdown)
.mode column 
.mode markdown

# Mostrar en la salida el timer de la consulta 
 .timer on

# Salir
.quit 
```

## Comandos SQL 
```sql
-- Mostrar Tablas
SHOW TABLES;

-- Describir las columnas de una tabla
DESCRIBE <table_name>;

-- Mostrar todas las tablas
SHOW ALL TABLES;

```

## Carga de datos 
1. Creamos la base -> Tabla y usamos el comando copy

```sql
COPY pet_licenses FROM 'Seattle_Pet_Licenses.csv' (
    FORMAT CSV,              -- tipo de archivo
    HEADER true,             -- la primera fila es el encabezado de columnas
    DELIMITER ',',          -- separador de campos (coma por defecto)
    DATEFORMAT '%B %d %Y'  -- formato de fecha: %B=nombre mes, %d=día, %Y=año 4 dígitos
    -- Ej: 'January 01 2023' → DATE '2023-01-01'
);
```

2. Cargamos en memoria para análisis rapdidos con 
- `read_csv` Debemos especificar como leer los dats
- `read_csv_auto` Infiere los tipos de datos 

```sql 
SELECT *
FROM read_csv_auto('Seattle_Pet_Licenses.csv')
LIMIT 5;

-- Ver qué tipos de dato detectó DuckDB automáticamente:
DESCRIBE SELECT * FROM read_csv_auto('Seattle_Pet_Licenses.csv');
```

**Especificando el tipo de dato con `read_csv`**
```sql
SELECT *
FROM read_csv(
    'Seattle_Pet_Licenses.csv',
    auto_detect  = false,          -- desactivar detección automática
    header       = true,           -- primera fila es encabezado
    delim        = ',',            -- separador de campos
    dateformat   = '%B %d %Y',   -- formato de fechas personalizado
    columns      = {               -- schema explícito: nombre_columna: tipo
        'License Issue Date': 'DATE',
        'License Number': 'VARCHAR',
        'Animal''s Name': 'VARCHAR',
        'Species': 'VARCHAR',
        'Primary Breed': 'VARCHAR',
        'Secondary Breed': 'VARCHAR',
        'ZIP Code': 'VARCHAR'
    }
)
LIMIT 5;
```

**Crear la tabla de la deteccion automática**
```sql
CREATE TABLE pet_licenses AS
SELECT * FROM read_csv_auto('Seattle_Pet_Licenses.csv');
```

**Manejo de Errores**
```sql
-- ignore_errors=true: DuckDB ignora filas malformadas en lugar de fallar
SELECT * FROM read_csv_auto(
    'datos_sucios.csv',
    ignore_errors = true  -- si una fila tiene error de parsing, la salta
);

-- null_padding=true: si una fila tiene menos columnas de las esperadas,
--   rellena las faltantes con NULL en vez de fallar
SELECT * FROM read_csv_auto(
    'datos_incompletos.csv',
    null_padding = true
);
```