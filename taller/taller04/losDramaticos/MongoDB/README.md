# MongoDB
## Integrantes
- Ivan Poma
- Valeria Zerain
Se uso el docker de la session-16:
```
version: '3.8'
services:
  mongo:
    image: mongo:6.0
    restart: always
    container_name: mongo
    ports:
      - '27017:27017'
    environment:
      MONGO_INITDB_ROOT_USERNAME: mongo
      MONGO_INITDB_ROOT_PASSWORD: mongo123
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
    driver: local
```
Este es el script en el cual estan las consultas en MongoDB
```
use medicCenter;
db.createCollection("turnos");
db.createCollection("doctores");
db.createCollection("pacientes");

//Doctores
db.doctores.insertMany([
    {
    _id: '2',
    nombre: "Miguel Gómez",
    especialidad: "Medicina General",
    email: "mgomez@vidasana.com"
    },
    {
    _id: '3',
    nombre: "Luciano Gómez",
    especialidad: "Medicina General",
    email: "lucigomez@vidasana.com"
    },
]);

db.doctores.find({});
db.pacientes.find({});

//Pacientes
db.pacientes.insertMany([
    {
      _id: '1',
      nombre: "Ana Pérez",
      edad: 23,
      telefonos: ["71234567", "71239876"],
      direccion: "Calle 123, Ciudad",
      estado: "pendiente",
      historial_medico: [
        {
          fecha: ISODate("2024-08-01"),
          diagnostico: "Gripe",
          tratamiento: "Reposo y líquidos"
        }
      ],
    },
    {
      _id: '2',
      nombre: "Jose Perez",
      edad: 40,
      telefonos: ["71234562", "71233876"],
      direccion: "Calle 456, Ciudad",
      estado: "confirmado",
      historial_medico: [
        {
          fecha: ISODate("2025-09-02"),
          diagnostico: "Tos",
          tratamiento: "Parecetamol y Miel"
        }
      ],
    },
    {
      _id: '3',
      nombre: "Jose Perez",
      edad: 42,
      telefonos: ["71234562", "71233876"],
      direccion: "Calle 456, Ciudad",
      estado: "cancelado",
      historial_medico: [
        {
          fecha: ISODate("2025-09-02"),
          diagnostico: "Tos",
          tratamiento: "Parecetamol y Miel"
        }
      ],
    },
    {
      _id: '4',
      nombre: "Jose Perez",
      edad: 45,
      telefonos: ["71234562", "71233876", "72564282"],
      direccion: "Calle 456, Ciudad",
      estado: "atendido",
      historial_medico: [
        {
          fecha: ISODate("2025-09-02"),
          diagnostico: "Tos",
          tratamiento: "Parecetamol y Miel"
        }
      ],
    },
]);

//Turnos
db.turnos.find({});
db.turnos.insertMany([
    {
      _id: '2',
      fecha_hora: ISODate("2025-06-16T08:30:00"),
      estado: "confirmado", // "pendiente", "cancelado", "atendido"
      comentarios_medicos: [
            "El paciente esta de alta",
            "No requiere un seguimiento"
      ],
      doctor_id: '2',
      paciente_id: '1'
    },
    {
      _id: '3',
      fecha_hora: ISODate("2025-06-17T08:30:00"),
      estado: "confirmado", // "pendiente", "cancelado", "atendido"
      comentarios_medicos: [
            "El paciente necesita reposo",
            "Requiere mas medicamentos"
      ],
      doctor_id: '2',
      paciente_id: '1'
    },

]);

db.turnos.find({
    fecha_hora: {$elemMatch: {fecha_hora: "2025-06-15T08:30:00", estado: "confirmado"}}
})

//Primera consulta
const doctor = db.doctores.findOne({ nombre: "Miguel Gómez" });

db.turnos.find({
  doctor_id: doctor._id,
  estado: "confirmado",
  fecha_hora: {
    $gte: ISODate("2025-06-15T00:00:00"),
    $lt: ISODate("2025-06-18T00:00:00")
  }
});

//Segunda Consulta
db.turnos.find(
  {
    doctor_id: doctor._id,
    estado: "confirmado",
    fecha_hora: {
      $gte: ISODate("2025-06-15T00:00:00"),
      $lt: ISODate("2025-06-18T00:00:00")
    }
  },
  { comentarios_medicos: 1 }
);

//Tercera consulta
db.pacientes.find({
    edad:{
        $gt:40
    },
    "telefonos.1": { $exists: true }
})

//Cuarta consulta

db.pacientes.find({
    estado: {$eq: "pendiente"}
});
```
