use hospitalDB

db.createCollection("doctores")
db.createCollection("pacientes")
db.createCollection("turnos")


const doctorId = db.doctores.insertOne({
  nombre: "Dr. Andres SAnchez",
  especialidad: "Medicina GEnereal"
})

const paciente1Id = db.pacientes.insertOne({
  nombre: "Luis Callapa",
  edad: 21,
  telefonos: ["78965412", "76543210"]
})

const paciente2Id = db.pacientes.insertOne({
  nombre: "Fernando Alcaraz",
  edad: 41,
  telefonos: ["78965412", "76543210"]
})

const paciente3Id = db.pacientes.insertOne({
  nombre: "Andrian Ledezma",
  edad: 40,
  telefonos: ["76543210", "123123123"]
})


db.turnos.insertMany([
  {
    fecha: "2025-06-15",
    hora: "08:00",
    estado: "confirmado",
    doctor_id: doctorId,
    paciente_id: paciente1Id,
    comentarios: [
      {  texto: "Paciente." },
      { texto: "Recetado paracetamol." }
    ]
  },
  {
    fecha: "2025-06-15",
    hora: "09:00",
    estado: "pendiente",
    doctor_id: doctorId,
    paciente_id: paciente2Id,
    comentarios: []
  },
  {
    fecha: "2025-06-16",
    hora: "10:00",
    estado: "pendiente",
    doctor_id: doctorId,
    paciente_id: paciente3Id,
    comentarios: []
  },
  {
    fecha: "2025-06-15",
    hora: "10:30",
    estado: "confirmado",
    doctor_id: doctorId,
    paciente_id: paciente3Id,
    comentarios: [
      {  texto: "Dolor en la rodilla." }
    ]
  }
])
// Necesito revisar mis turnos del 15 de junio de 2025. Solo los confirmados.
db.turnos.find({
  fecha: "2025-06-15",
  estado: "confirmado"
})

//Quiero ver todos los comentarios médicos registrados en esos turnos.

db.turnos.find({
  fecha: "2025-06-15",
  estado: "confirmado"
},
    {
    _id: 0,
    comentarios: 1
  }
)

// ¿Cuántos pacientes tengo con más de 40 años y al menos dos teléfonos registrados?
db.pacientes.find({
  $and: [
    { edad: { $gt: 40 } },
    { telefonos: { $exists: true } },
    { $expr: { $gte: [{ $size: "$telefonos" }, 2] } }
  ]
});

db.turnos.find({
  $and: [
    { id_doctor: "Fernando Alcaraz" },
    { estado: "pendiente" }
  ]
    }
    )

//Necesito ver los pacientes que tienen turnos pendientes aún sin atender.
db.turnos.find(
  { estado: "pendiente" },
  { _id: 0, paciente_id: 1 }
)
