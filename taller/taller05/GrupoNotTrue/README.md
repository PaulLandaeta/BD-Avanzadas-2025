1. Extracción (Extract)
Descripción
La fase de extracción consiste en obtener los datos necesarios de la base de datos transaccional dvdrental para alimentar el Data Warehouse. Se identificaron los atributos relevantes basados en las consultas requeridas, incluyendo hechos (ventas) y dimensiones (tiempo, geografía, películas, clientes).

Pasos
Identificación de Datos Relevantes:
Hechos: amount (monto de pago) de la tabla payment.
Dimensiones:
Tiempo: payment_date de payment para extraer año y mes.
Geografía (Tienda): store_id, city, country de store, address, city y country.
Geografía (Cliente): city, country de la dirección del cliente.
Película: film_id, title, rating, genre de film y category.
Cliente: customer_id, first_name, last_name de customer.


2. Transformación (Transform)
Descripción
La transformación convierte los datos extraídos en un formato adecuado para el Data Warehouse, eliminando duplicados, agregando información y estructurando las dimensiones. Se crearon tablas temporales o se ajustaron los datos para alinearse con el esquema estrella.

Pasos
Estructuración de Dimensiones:
Dim_Tiempo: Se extrajeron año y mes de payment_date como valores únicos.
Dim_Country: Se seleccionaron países únicos de las tablas country.
Dim_Store: Se relacionaron tiendas con ciudades y países, normalizando los datos.
Dim_Customer: Se extrajeron identificadores y nombres de clientes sin duplicados.
Dim_Film: Se tomaron títulos y ratings de películas directamente de film.
Transformación de Datos:
Se usaron funciones como EXTRACT para desglosar fechas.
Se eliminaron duplicados con DISTINCT para asegurar integridad en las dimensiones.


3. Carga (Load)
Descripción
La fase de carga inserta los datos transformados en las tablas del esquema estrella en la base de datos dvd_estrella. Se utilizaron consultas de inserción para poblar las dimensiones y la tabla de hechos.

Pasos
Conexión a la Base de Datos: Se conectó a dvdrental para extraer los datos, ya que las referencias cruzadas entre bases de datos no están soportadas directamente en PostgreSQL.
Después de eso con los scripts que se subio en el conjunto, se hizo la inserción de todos los datos en las nuevas tablas