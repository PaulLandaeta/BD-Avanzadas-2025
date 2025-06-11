use clinica_salud;

db.createCollection("clientes");
db.createCollection("medicos");
db.createCollection("citas");

db.medicos.insertMany([
    {
        _id: "med1",
        nombre: "Dr. Miguel Torres",
        especialidad: "Medicina Interna",
        contacto: { telefono: "77712345", email: "migueltorres@clinica.com" }
    },
    {
        _id: "med2",
        nombre: "Dra. Sofia Vargas",
        especialidad: "Cardiología",
        contacto: { telefono: "77767890", email: "sofiavargas@clinica.com" }
    },
    {
        _id: "med3",
        nombre: "Dr. Carlos Mendoza",
        especialidad: "Pediatría",
        contacto: { telefono: "77754321", email: "carlosmendoza@clinica.com" }
    }
]);

db.clientes.insertMany([
    {
        _id: "cli1",
        nombre: "Laura Gonzales",
        edad: 28,
        telefonos: ["77711122"],
        direccion: { calle: "Av. Sol 123", ciudad: "La Paz", departamento: "LP" },
        historial: [
            { fecha: ISODate("2025-01-15"), diagnostico: "Resfriado", tratamiento: "Antibióticos" }
        ]
    },
    {
        _id: "cli2",
        nombre: "Pablo Rojas",
        edad: 47,
        telefonos: ["77755566"],
        direccion: { calle: "Calle Luna 456", ciudad: "Cochabamba", departamento: "CB" },
        historial: []
    },
    {
        _id: "cli3",
        nombre: "Carla Lopez",
        edad: 55,
        telefonos: ["77799900"],
        direccion: { calle: "Av. Estrella 789", ciudad: "Santa Cruz", departamento: "SC" },
        historial: []
    },
    {
        _id: "cli4",
        nombre: "Juan Morales",
        edad: 35,
        telefonos: ["77744455"],
        direccion: { calle: "Calle Sol 101", ciudad: "Oruro", departamento: "OR" },
        historial: []
    },
    {
        _id: "cli5",
        nombre: "Elena Suarez",
        edad: 43,
        telefonos: ["77766677"],
        direccion: { calle: "Av. Luna 202", ciudad: "Tarija", departamento: "TA" },
        historial: []
    },
    {
        _id: "cli6",
        nombre: "Marcos Perez",
        edad: 50,
        telefonos: ["77700011"],
        direccion: { calle: "Calle Estrella 303", ciudad: "Sucre", departamento: "SU" },
        historial: []
    },
    {
        _id: "cli7",
        nombre: "Sofia Castro",
        edad: 38,
        telefonos: ["77722233"],
        direccion: { calle: "Av. Sol 404", ciudad: "La Paz", departamento: "LP" },
        historial: []
    },
    {
        _id: "cli8",
        nombre: "Diego Vargas",
        edad: 46,
        telefonos: ["77733344"],
        direccion: { calle: "Calle Luna 505", ciudad: "Cochabamba", departamento: "CB" },
        historial: []
    },
    {
        _id: "cli9",
        nombre: "Valeria Ortiz",
        edad: 41,
        telefonos: ["77766688"],
        direccion: { calle: "Av. Estrella 606", ciudad: "Santa Cruz", departamento: "SC" },
        historial: []
    },
    {
        _id: "cli10",
        nombre: "Rodrigo Diaz",
        edad: 32,
        telefonos: ["77788800"],
        direccion: { calle: "Calle Sol 707", ciudad: "Oruro", departamento: "OR" },
        historial: []
    }
]);

db.citas.insertMany([
    {
        _id: "cita1",
        cliente_id: "cli1",
        medico_id: "med1",
        fecha_hora: ISODate("2025-06-15T09:00:00Z"),
        estado: "confirmado",
        observaciones: [
            { texto: "Paciente con fiebre alta", fecha: ISODate("2025-06-15T09:15:00Z") },
            { texto: "Recetado ibuprofeno", fecha: ISODate("2025-06-15T09:30:00Z") }
        ]
    },
    {
        _id: "cita2",
        cliente_id: "cli2",
        medico_id: "med1",
        fecha_hora: ISODate("2025-06-15T10:30:00Z"),
        estado: "confirmado",
        observaciones: [
            { texto: "Dolor torácico leve", fecha: ISODate("2025-06-15T10:45:00Z") }
        ]
    },
    {
        _id: "cita3",
        cliente_id: "cli3",
        medico_id: "med1",
        fecha_hora: ISODate("2025-06-15T11:00:00Z"),
        estado: "pendiente",
        observaciones: []
    },
    {
        _id: "cita4",
        cliente_id: "cli4",
        medico_id: "med1",
        fecha_hora: ISODate("2025-06-16T12:00:00Z"),
        estado: "pendiente",
        observaciones: []
    },
    {
        _id: "cita5",
        cliente_id: "cli5",
        medico_id: "med2",
        fecha_hora: ISODate("2025-06-15T14:00:00Z"),
        estado: "confirmado",
        observaciones: [
            { texto: "Control de hipertensión", fecha: ISODate("2025-06-15T14:15:00Z") }
        ]
    }
]);

db.citas.updateOne(
    { _id: "cita1" },
    {
        $set: {
            observaciones: [
                { texto: "Paciente estable, continuar tratamiento", fecha: ISODate("2025-06-15T09:45:00Z") }
            ]
        }
    }
);

const medico = db.medicos.findOne({ nombre: "Dr. Miguel Torres" });
db.citas.find({
    medico_id: medico._id,
    estado: "confirmado",
    fecha_hora: {
        $gte: ISODate("2025-06-15T00:00:00Z"),
        $lt: ISODate("2025-06-16T00:00:00Z")
    }
});

db.citas.find(
    {
        medico_id: medico._id,
        estado: "confirmado",
        fecha_hora: {
            $gte: ISODate("2025-06-15T00:00:00Z"),
            $lt: ISODate("2025-06-16T00:00:00Z")
        }
    },
    { observaciones: 1, _id: 0 }
);

db.clientes.find({
    $and: [
        { edad: { $gt: 40 } },
        { telefonos: { $exists: true, $type: "array" } },
        { $expr: { $gte: [{ $size: "$telefonos" }, 2] } }
    ]
});

db.citas.aggregate([
    { $match: { estado: "pendiente" } },
    {
        $lookup: {
            from: "clientes",
            localField: "cliente_id",
            foreignField: "_id",
            as: "cliente_info"
        }
    },
    { $unwind: "$cliente_info" },
    {
        $project: {
            _id: 0,
            nombre_cliente: "$cliente_info.nombre",
            fecha_cita: "$fecha_hora",
            estado: 1
        }
    }
]);