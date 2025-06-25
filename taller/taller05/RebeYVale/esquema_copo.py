import pandas as pd
import psycopg2

# Leer el CSV
df = pd.read_csv('./Result_5.csv')

# Conectar a PostgreSQL
conn = psycopg2.connect(
    dbname="dvdrental",
    user="rebe",
    password="rebe123",
    host="localhost",
    port="5432"
)
cursor = conn.cursor()

# Crear esquema copo de nieve
cursor.execute("CREATE SCHEMA IF NOT EXISTS esquema_copo")

# Crear tablas
cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_copo.dim_tiempo (
    id_tiempo SERIAL PRIMARY KEY,
    fecha_renta DATE UNIQUE,
    año INTEGER,
    mes INTEGER,
    dia INTEGER
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_copo.dim_ubicacion (
    id_ubicacion SERIAL PRIMARY KEY,
    ciudad TEXT,
    pais TEXT,
    direccion TEXT,
    UNIQUE(ciudad, pais, direccion)
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_copo.dim_tienda (
    id_tienda SERIAL PRIMARY KEY,
    nombre TEXT,
    id_ubicacion INTEGER REFERENCES esquema_copo.dim_ubicacion(id_ubicacion),
    empleado TEXT,
    UNIQUE(nombre, id_ubicacion, empleado)
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_copo.dim_cliente (
    id_cliente SERIAL PRIMARY KEY,
    nombre TEXT,
    apellido TEXT,
    UNIQUE(nombre, apellido)
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_copo.dim_pelicula (
    id_pelicula SERIAL PRIMARY KEY,
    nombre TEXT,
    categoria TEXT,
    rating TEXT,
    UNIQUE(nombre, categoria, rating)
)
''')

cursor.execute('''
CREATE TABLE IF NOT EXISTS esquema_copo.hechos_ventas (
    id_venta SERIAL PRIMARY KEY,
    id_tiempo INTEGER REFERENCES esquema_copo.dim_tiempo(id_tiempo),
    id_tienda INTEGER REFERENCES esquema_copo.dim_tienda(id_tienda),
    id_cliente INTEGER REFERENCES esquema_copo.dim_cliente(id_cliente),
    id_pelicula INTEGER REFERENCES esquema_copo.dim_pelicula(id_pelicula),
    monto REAL
)
''')

conn.commit()

# Función auxiliar para insertar o devolver ID
def get_or_insert(cursor, schema, table, unique_fields, values_dict):
    condition = ' AND '.join([f"{field} = %s" for field in unique_fields])
    select_query = f"SELECT id_{table[4:]} FROM {schema}.{table} WHERE {condition}"
    cursor.execute(select_query, tuple(values_dict[field] for field in unique_fields))
    row = cursor.fetchone()

    if row:
        return row[0]
    else:
        columns = ', '.join(values_dict.keys())
        placeholders = ', '.join(['%s'] * len(values_dict))
        insert_query = f"INSERT INTO {schema}.{table} ({columns}) VALUES ({placeholders}) RETURNING id_{table[4:]}"
        cursor.execute(insert_query, tuple(values_dict.values()))
        return cursor.fetchone()[0]

# Insertar datos en las tablas normalizadas
for _, row in df.iterrows():
    fecha = row['payment_date'][:10]
    año, mes, dia = map(int, fecha.split('-'))
    id_tiempo = get_or_insert(cursor, 'esquema_copo', 'dim_tiempo',
        ['fecha_renta'],
        {'fecha_renta': fecha, 'año': año, 'mes': mes, 'dia': dia}
    )

    id_ubicacion = get_or_insert(cursor, 'esquema_copo', 'dim_ubicacion',
        ['ciudad', 'pais', 'direccion'],
        {
            'ciudad': row['city'],
            'pais': row['country'],
            'direccion': row['address']
        }
    )

    id_tienda = get_or_insert(cursor, 'esquema_copo', 'dim_tienda',
        ['nombre', 'id_ubicacion', 'empleado'],
        {
            'nombre': str(row['store_id']),
            'id_ubicacion': id_ubicacion,
            'empleado': row['first_name']
        }
    )

    id_cliente = get_or_insert(cursor, 'esquema_copo', 'dim_cliente',
        ['nombre', 'apellido'],
        {
            'nombre': row['first_name'],
            'apellido': row['last_name']
        }
    )

    id_pelicula = get_or_insert(cursor, 'esquema_copo', 'dim_pelicula',
        ['nombre', 'categoria', 'rating'],
        {
            'nombre': row['title'],
            'categoria': row['name'],
            'rating': row['rating']
        }
    )

    cursor.execute('''
        INSERT INTO esquema_copo.hechos_ventas (id_tiempo, id_tienda, id_cliente, id_pelicula, monto)
        VALUES (%s, %s, %s, %s, %s)
    ''', (id_tiempo, id_tienda, id_cliente, id_pelicula, row['amount']))

# Confirmar
conn.commit()
cursor.close()
conn.close()

print("✅ Datos insertados correctamente en modelo Copo de Nieve (esquema_copo).")
