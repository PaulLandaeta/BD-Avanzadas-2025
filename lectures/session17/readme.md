use upb;

show dbs;

// Seleccionar la base de datos
use upb;
// es como si fuera una tabla en SQL
db.createCollection("students");



db.students.insertOne({
    name: "John Doe",
    age: 20,
    major: "Computer Science",
    enrolled: true,
    lastname: "Doe",
    address: {
        street: "123 Main St",
        city: "Anytown",
        state: "CA",
        zip: "12345"
    },
});

db.students.insertOne({
    name: "Juan Perez",
    student_id: 2,
    age: 22,
    major: "Computer Science",
    enrolled: false,
    lastname: "Doe",
    mother: {
        name: "Jane Doe",
        age: 45,
        occupation: "Engineer"
    },
});



use upb;
// find es muy similar a lo que es select en BDR
db.students.find({});
// select * from students;

// como puedo filtrar a mis estudiantes mayores a 20 años
// select * from students where age >= 22
db.students.find({
age: {
    $gte: 22
    }
});

// mostrar a los estudiantes mayores o igual a  18 y menores o igual a 21
db.students.find({
    age: {
        $gte: 18, $lte: 21
    }
});


// Buscar al studiante Juan Perez

db.students.find({
    name: "Juan Perez"
});


// UPDATE in MongoDB

// updateOne, update, replaceOne()

// updateOne({filtro})

db.students.updateOne({
    name: "John Doe"
    },
    {
        $set: { age: 18, lastname: 'Landaeta'}
    }
);

// replaceOne
// db.students.replaceOne({filtro}, {newValue})

//Replace funciona como si remplazaramos el objeto completo

// Ejemplo
// studentOne = { name: 'Paul', last_name: 'Landaeta', degree: 'Lic'}

// replaces
// studentTwo = { name: 'Wilker', carrer: 'Informatic' }

/// studentOne = studentTwo;

// console.log(studentOne);

//   { name: 'Wilker', carrer: 'Informatic' }



db.students.replaceOne(
    {name: 'John Doe'},
    { stock: 20, quantity: 10}
);





db.students.find({});


db.students.updateOne({
    major: 'Computer Science'
},
 {$set: { age: 25}}
);


db.students.find({});

// CURSOR = PUNTERO
db.students.find({
    age: { $lt : 20}
}).forEach(function(student) {
    print(student.name);
});


db.students.find({}).limit(8);


db.students.find({}).skip(10).limit(5);


db.students.find({}).sort({age: -1});

// Proyecciones
// seleccionar los atributos a visualizar
// select age, enrolled, mother.name from students
db.students.find({});
db.students.find({}, {_id: 0, age: 1, enrolled: 1, 'mother.name': 1});



// Schemas Fijos y Schemas Dinamicos
// Dinamico es por defecto
use upb;

db.createCollection("subjects");

db.subjects.insertOne({
 name: 'BD Relaciones',
 semestre: '2025'
});

db.subjects.insertOne({
 name: 'Algoritmica',
 prerequisito: 'Programacion III',
});

db.subjects.find({});

// SCHEMA FIJO
db.createCollection("clients", {
  validator: {
     $jsonSchema: {
        bsonType: 'object',
        required: ['email', 'name'],
        properties: {
           name: {
             bsonType: "string",
             description: " Debe ser una cadena",
           },
           age: {
              bsonType: "int",
              minimum: 18,
              description: " Debe ser un entero mayor a 18",
           },
          email: {
           bsonType: "string",
           description: " Debe ser un email valido",
         }
        }
     }
  }
});

db.clients.insertOne({
age:19,
name: 'paul',
email: 'paul@gmial.com'
});



