use hospital;

db.createCollection("patients");

db.createCollection("doctors");

db.createCollection("appointments")


    db.patients.insertOne({
        _id: 1,
        name: "Carlos Perez",
        age: 35,
        gender: "male",
        phone: "12345678",
        address: {
            street: "Av. Siempre Viva 123",
            city: "La Paz",
            state: "LP"
            },
        medicalHistory: [
            {
                date: ISODate("2025-01-10"),
                diagnosis: "Gripe",
                treatment: "Reposo y paracetamol"
                },
            {
                date: ISODate("2025-03-20"),
                diagnosis: "Dolor de espalda",
                treatment: "Fisioterapia"
                }
            ]
        });

    db.patients.find();


    db.doctors.insertOne({
        _id: 1,
        name: "Dr. Miguel Gómez",
        specialty: "Medicina General",
        phone: "87654321",
        email: "miguelgomez@hospital.com"
        });

    db.doctors.find();

    db.appointments.insertOne({
        _id: 1,
        patient_id: 1,
        doctor_id: 1,
        date: ISODate("2025-06-11T10:00:00Z"),
        status: "scheduled",
        notes: "Paciente con síntomas de gripe"
        });
    db.appointments.find()

    const patients = [
        {
            _id: 2,
            name: "Sofía Pérez",
            age: 45,
            gender: "female",
            phone: ["44444444", "55555555"],
            address: { street: "Calle 3", city: "Santa Cruz", state: "SC" },
            medicalHistory: []
            },
        {            _id: 3,
            name: "Carlos Ruiz",
            age: 38,
            gender: "male",
            phone: ["66666666", "77777777"],
            address: { street: "Calle 4", city: "La Paz", state: "LP" },
            medicalHistory: []
            },
        {
            _id: 4,
            name: "Lucía Morales",
            age: 41,
            gender: "female",
            phone: ["11121314", "15161718"],
            address: { street: "Calle 7", city: "Oruro", state: "OR" },
            medicalHistory: []
            },
        {
            _id: 5,
            name: "Jorge Fernández",
            age: 36,
            gender: "male",
            phone: ["19202122"],
            address: { street: "Calle 8", city: "Tarija", state: "TA" },
            medicalHistory: []
            },
        {            _id: 6,
            name: "Miguel Sánchez",
            age: 52,
            gender: "male",
            phone: ["31323334", "35363738"],
            address: { street: "Calle 10", city: "Beni", state: "BE" },
            medicalHistory: []
            },
        {            _id: 7,
            name: "Patricia Díaz",
            age: 39,
            gender: "female",
            phone: ["39404142"],
            address: { street: "Calle 11", city: "La Paz", state: "LP" },
            medicalHistory: []
            },
        {
            _id: 8,
            name: "Fernando Herrera",
            age: 43,
            gender: "male",
            phone: ["43444546", "47484950"],
            address: { street: "Calle 12", city: "Cochabamba", state: "CB" },
            medicalHistory: []
            },
        {            _id: 9,
            name: "Andrés Romero",
            age: 46,
            gender: "male",
            phone: ["55565758", "59606162"],
            address: { street: "Calle 14", city: "La Paz", state: "LP" },
            medicalHistory: []
            },
        {
            _id: 10,
            name: "Natalia Castro",
            age: 34,
            gender: "female",
            phone: ["63646566"],
            address: { street: "Calle 15", city: "Sucre", state: "SU" },
            medicalHistory: []
            },
        {
            _id: 11,
            name: "Ricardo Flores",
            age: 40,
            gender: "male",
            phone: ["67686970"],
            address: { street: "Calle 16", city: "Oruro", state: "OR" },
            medicalHistory: []
            },
        ];

    patients.forEach(p => db.patients.insertOne(p));

    db.appointments.insertMany([
        {
            _id: 2,
            patient_id: 2,
            doctor_id: 1,
            date: ISODate("2025-06-15T09:00:00Z"),
            status: "confirmed",
            notes: "Consulta general"
            },
        {
            _id: 3,
            patient_id: 4,
            doctor_id: 1,
            date: ISODate("2025-06-15T11:00:00Z"),
            status: "scheduled",
            notes: "Chequeo anual"
            },
        {
            _id: 4,
            patient_id: 6,
            doctor_id: 1,
            date: ISODate("2025-06-15T14:00:00Z"),
            status: "confirmed",
            notes: "Consulta de seguimiento"
            }
        ]);
    db.appointments.find();


    db.doctors.insertMany([
        {
            _id: 2,
            name: "Dr. Paul Ramírez",
            specialty: "Cardiología",
            phone: "55512345",
            email: "paul.ramirez@hospital.com"
            },
        {
            _id: 3,
            name: "Dra. Rebeca Morales",
            specialty: "Pediatría",
            phone: "55567890",
            email: "rebeca.morales@hospital.com"
            }
        ]);

    db.doctors.find();

    db.appointments.insertMany([
        {
            _id: 10,
            patient_id: 2,
            doctor_id: 2,
            date: ISODate("2025-06-15T09:00:00Z"),
            status: "pending",
            notes: "Chequeo general"
            },
        {            _id: 11,
            patient_id: 6,
            doctor_id: 3,
            date: ISODate("2025-06-15T11:00:00Z"),
            status: "confirmed",
            notes: "Control de presión arterial"
            },
        {
            _id: 12,
            patient_id: 7,
            doctor_id: 2,
            date: ISODate("2025-06-15T14:00:00Z"),
            status: "scheduled",
            notes: "Consulta de dermatología"
            }
        ]);
    db.appointments.insertMany([
        {
            _id: 13,
            patient_id: 2,
            doctor_id: 2,
            date: ISODate("2025-06-15T09:00:00Z"),
            status: "confirmed",
            notes: "Consulta general"
            },
        {
            _id: 14,
            patient_id: 5,
            doctor_id: 1,
            date: ISODate("2025-06-15T10:30:00Z"),
            status: "confirmed",
            notes: "Chequeo anual"
            },
        {
            _id: 16,
            patient_id: 1,
            doctor_id: 2,
            date: ISODate("2025-06-15T14:00:00Z"),
            status: "confirmed",
            notes: "Dolor de cabeza"
            }
        ]);

    db.appointments.updateOne(
        { _id: 16 },
        {
            $set: {
                notes: "El paciente solo tenía dolor de estómago, no necesita operación"
                }
            }
        );

    db.appointments.updateOne(
        { _id: 16 },
        {
            $set: {
                comments: "El paciente solo tenía dolor de estómago, no necesita operación"
                }
            }
        );

    // 1ER EJERCICIO
    //  - Necesito revisar mis turnos del 15 de junio de 2025. Solo los confirmados.


    db.appointments.find({
        date: {
            $gte: ISODate("2025-06-15T00:00:00Z"),
            $lt: ISODate("2025-06-16T00:00:00Z")
            },
        status:"confirmed"
        });

    // EJERCICIO 2
    //
    db.appointments.find(
        {
            date: {
                $gte: ISODate("2025-06-15T00:00:00Z"),
                $lt: ISODate("2025-06-16T00:00:00Z")
                },
            status: "confirmed"
            }, { doctor_id: 1, comments:1}

        );

    //3

    db.patients.find({
        age: { $gt: 40 },
        phone: { $exists: true, $type: "array" },
        $expr: { $gte: [{ $size: "$phone" }, 2] }
        });

    //4
    //
        db.appointments.aggregate([
        { $match: { status: "pending" } },
        {
            $lookup: {
                from: "patients",
                localField: "patient_id",
                foreignField: "_id",
                as: "patientInfo"
                }
            },
        { $unwind: "$patientInfo" },
        {
            $project: {
                _id: 0,
                patientName: "$patientInfo.name",
                appointmentDate: "$date",
                status: 1
                }
            }
        ]);

   
        