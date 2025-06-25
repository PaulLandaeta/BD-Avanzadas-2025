import pandas as pd
import psycopg2

# Cargar CSV
df = pd.read_csv('./Result_5.csv')

# Conexión a PostgreSQL
conn = psycopg2.connect(
    dbname="dvdrental",

    user="rebe",
    password="rebe123",
    host="localhost",
    port="5432"
)
cursor = conn.cursor()

# Crear esquema
cursor.execute("CREATE SCHEMA IF NOT EXISTS esquema_estrella")

# Crear tablas dentro del esquema
cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_estrella.dim_tiempo (
    id_tiempo SERIAL PRIMARY KEY,
    año INTEGER,
    mes INTEGER,
    dia INTEGER,
    fecha_renta DATE UNIQUE
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_estrella.dim_tienda (
    id_tienda SERIAL PRIMARY KEY,
    nombre_tienda TEXT,
    ciudad TEXT,
    pais TEXT,
    direccion TEXT,
    empleado TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_estrella.dim_pelicula (
    id_pelicula SERIAL PRIMARY KEY,
    nombre TEXT,
    categoria TEXT,
    rating TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_estrella.dim_cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre TEXT,
    apellido TEXT
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_estrella.hechos_ventas (
    id_venta SERIAL PRIMARY KEY,
    id_tiempo INTEGER REFERENCES esquema_estrella.dim_tiempo(id_tiempo),
    id_tienda INTEGER REFERENCES esquema_estrella.dim_tienda(id_tienda),
    id_pelicula INTEGER REFERENCES esquema_estrella.dim_pelicula(id_pelicula),
    id_cliente INTEGER REFERENCES esquema_estrella.dim_cliente(id_cliente),
    monto REAL
)
''')

conn.commit()

# Función auxiliar para insertar o retornar ID
def get_or_insert(cursor, table, unique_fields, values_dict):
    full_table = f"esquema_estrella.{table}"
    condition = ' AND '.join([f"{field} = %s" for field in unique_fields])
    select_query = f"SELECT id_{table[4:]} FROM {full_table} WHERE {condition}"
    cursor.execute(select_query, tuple(values_dict[field] for field in unique_fields))
    row = cursor.fetchone()

    if row:
        return row[0]
    else:
        columns = ', '.join(values_dict.keys())
        placeholders = ', '.join(['%s'] * len(values_dict))
        insert_query = f"INSERT INTO {full_table} ({columns}) VALUES ({placeholders}) RETURNING id_{table[4:]}"
        cursor.execute(insert_query, tuple(values_dict.values()))
        return cursor.fetchone()[0]

# Insertar datos en el esquema
for _, row in df.iterrows():
    fecha = row['payment_date'][:10]
    año, mes, dia = map(int, fecha.split('-'))
    id_tiempo = get_or_insert(cursor, 'dim_tiempo',
        ['fecha_renta'],
        {'año': año, 'mes': mes, 'dia': dia, 'fecha_renta': fecha}
    )

    id_tienda = get_or_insert(cursor, 'dim_tienda',
        ['nombre_tienda', 'ciudad', 'pais', 'direccion', 'empleado'],
        {
            'nombre_tienda': str(row['store_id']),

            'ciudad': row['city'],
            'pais': row['country'],
            'direccion': row['address'],
            'empleado': row['first_name']
        }
    )

    id_pelicula = get_or_insert(cursor, 'dim_pelicula',
        ['nombre', 'categoria', 'rating'],
        {
            'nombre': row['title'],
            'categoria': row['name'],
            'rating': row['rating']
        }
    )

    id_cliente = get_or_insert(cursor, 'dim_cliente',
        ['nombre', 'apellido'],
        {
            'nombre': row['first_name'],
            'apellido': row['last_name']
        }
    )

    cursor.execute('''
        INSERT INTO esquema_estrella.hechos_ventas 
        (id_tiempo, id_tienda, id_pelicula, id_cliente, monto)
        VALUES (%s, %s, %s, %s, %s)
    ''', (id_tiempo, id_tienda, id_pelicula, id_cliente, row['amount']))

# Finalizar
conn.commit()
cursor.close()
conn.close()

print("✅ Datos cargados en PostgreSQL dentro del esquema 'esquema_estrella'.")
