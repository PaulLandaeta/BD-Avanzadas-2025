use hospital_vida_sana;

    db.createCollection("pacientes");

    db.createCollection("turnos");

    db.pacientes.insertMany([
        { _id: "paciente1", nombre: "Diego Ledezma", edad: 45, telefonos: ["77750575", "77757539"] },
        { _id: "paciente2", nombre: "Luis Callapa", edad: 50, telefonos: ["77574748"] },
        { _id: "paciente3", nombre: "Ernesto Juarez", edad: 30, telefonos: ["77278923", "77739222"] },
        { _id: "paciente4", nombre: "Andres Sanchez", edad: 42, telefonos: ["77793022", "77723627"] },
        { _id: "paciente5", nombre: "Zein Tonconi", edad: 60, telefonos: ["777798300", "77738889"] }
        ]);

    db.pacientes.find({});


    db.turnos.insertMany([
        {
            id_paciente: "paciente1",
            id_doctor: "Dr. Miguel Gómez",
            fecha: "2025-15-06 09:30",
            estado: "confirmado",
            comentarios: [
                { texto: "Paciente con ansiedad por BD Avanzadas", fecha: "2025-15-06 09:50" },
                { texto: "Necesita descanso URGENTE :O", fecha: "2025-15-06 10:00" }
                ]
            },
        {
            id_paciente: "paciente2",
            id_doctor: "Dr. Miguel Gómez",
            fecha: "2025-15-06 10:00",
            estado: "confirmado",
            comentarios: [
                { texto: "Caida de cabello y estres por Practica Interna", fecha: "2025-30-08 10:45" }
                ]
            },
        {
            id_paciente: "paciente3",
            id_doctor: "Dr. Miguel Gómez",
            fecha: "2025-15-06 11:00",
            estado: "pendiente",
            comentarios: []
            },
        {
            id_paciente: "paciente4",
            id_doctor: "Dr. Miguel Gómez",
            fecha: "2025-13-10 12:00",
            estado: "pendiente",
            comentarios: []
            }
        ]);

db.turnos.find({
  $and: [
    { id_doctor: "Dr. Miguel Gómez" },
    { estado: "confirmado" },
    { fecha: { $regex: "^2025-15-06" } } //Esto es equivalente al 'a%' de sql para empiece ya que no usamos date en las fechas
  ]
});

db.turnos.find({
  $and: [
    { id_doctor: "Dr. Miguel Gómez" },
    { estado: "confirmado" },
    { fecha: { $regex: "^2025-15-06" } }
  ]
}, { comentarios: 1, _id: 0 });

db.pacientes.find({
  $and: [
    { edad: { $gt: 40 } },
    { telefonos: { $exists: true } },
    { $expr: { $gte: [{ $size: "$telefonos" }, 2] } }
  ]
});

db.turnos.find({
  $and: [
    { id_doctor: "Dr. Miguel Gómez" },
    { estado: "pendiente" }
  ]
});