# Extracción 
Se extrae de PostgreSQL de la base de datos de dvdrental los datos necesarios para satisfacer las consultas, este se extrae como un CSV y es el que servirá para posteriormente cargarlo en el script de Pyhton
# Transformación
Con el script de python esquema_estrella.py se extraen los datos necesarios.
Con el script de python esquema_copodenieve.py se extraen los datos necesarios.
# Load
Los datos de ambos casos se cargan en PostgreSQL, se crean dos esquemas dentro del dvdrental, uno es estrella y el otro es copo, en estos se cargan los datos desde el script de python.
### Esquema de copo de nieve
![image](https://github.com/user-attachments/assets/ba7f5794-8966-4c7b-a7ff-dd29ddb314e4)

### Esquema estrella
![image](https://github.com/user-attachments/assets/0d9f4f02-a3b8-482d-8612-fadb81f2b880)
