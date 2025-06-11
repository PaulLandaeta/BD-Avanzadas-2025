// Backend NoSQL -> Validacion Backend
db.clients.find({});

// Queries
// Tipos
nombre = 'Paul';
print(nombre);

isActive = true;
print(isActive);

// BJSON
date = ISODate('2025-06-10T00:00:00Z');
print(date);

// array = list
products = ['papaya', 'platano', 'manzana'];
print(products)

// number float

age = 20;
price = 1.2;
print(age, price);

// Queries


use dameGasolina;

db.createCollection("estacion");
show collections;
db.estacion.find({});

db.estacion.insertMany([
    {
        _id: '1',
        nombre: 'Volcan',
        direccion: {
            lat: 123123123,
            log: 123123532
        },
        horarios: [
            {
                dia: 'lunes',
                open: '20:00',
                closed: '22:00'
            },
            {
                dia: 'martes',
                open: '20:00',
                closed: '22:00'
            },
            {
                dia: 'miercoles',
                open: '20:00',
                closed: '22:00'
            }
        ],
        nroMangueras: 6,
        servicios: [{
                nombre: 'diesel',
                precio: 8,
                tanque: 2000,
                stock: 1500
            },{
                nombre: 'gasolina',
                precio: 3.6,
                tanque: 5000,
                stock: 2000
            }
        ]
    },
        {
            _id: '2',
            nombre: 'Automovil Club',
            direccion: {
                lat: 123123123,
                log: 123123532
            },
            horarios: [
                {
                    dia: 'lunes',
                    open: '09:00',
                    closed: '22:00'
                },
                {
                    dia: 'martes',
                    open: '09:00',
                    closed: '22:00'
                },
                {
                    dia: 'miercoles',
                    open: '09:00',
                    closed: '22:00'
                }
            ],
            nroMangueras: 4,
            servicios: [{
                    nombre: 'gasolina',
                    precio: 3.6,
                    tanque: 5000,
                    stock: 2000
                }
            ]
        }
])

db.estacion.find({});


// >=
db.estacion.find({
    nroMangueras: { $gte: 5}
});
// ==
db.estacion.find({
nroMangueras: {$eq: 4}
});

// !=
db.estacion.find({
nroMangueras: {$ne: 4}
});

// Logicos
// and , or , nor , not
// cual es la estacion que tiene latitud 123123123 y tiene mas de 4 mangueras

db.estacion.find({
    $and:[{'direccion.lat': {$eq: 123123123}},{ nroMangueras: {$gt: 4}}]
});
// or

db.estacion.find({
    $or:[{'direccion.lat': {$eq: 123123123}},{ nroMangueras: {$gt: 4}}]
});


db.estacion.find({
    $nor:[{'direccion.lat': {$eq: 1231231223}},{ nroMangueras: {$lt: 2}}]
});





// not (manguer!=4)
// !(mague==4)

db.estacion.find({
    nroMangueras: {$not: {$eq: 4}}
});

// exists validar si existe un atributo dentro de un documento
db.estacion.find({
    'direccion.log': {$exists: true}
});

db.estacion.insertOne({
    _id: '3',
    name: 'Tupac Katari'
});

db.estacion.find({
    'nombre': {$exists: true}
});

// operadores dentro de un array
// elementMatch

 //lat: 123123123,
 // log: 123123532
db.estacion.find({
        horarios: { $elemMatch: { dia: 'lunes', dia: 'miercoles'}}
   }
);

db.estacion.insertOne({
            _id: '4',
                              nombre: 'Cementerio',
                              direccion: {
                                  lat: 123123123,
                                  log: 123123532
                              },
                              horarios: [
                                  {
                                      dia: 'lunes',
                                      open: '20:00',
                                      closed: '22:00'
                                  },
                                  {
                                      dia: 'martes',
                                      open: '20:00',
                                      closed: '22:00'
                                  },
                              ],
                              nroMangueras: 6,
                              servicios: [{
                                      nombre: 'diesel',
                                      precio: 8,
                                      tanque: 2000,
                                      stock: 1500
                                  },{
                                      nombre: 'gasolina',
                                      precio: 3.6,
                                      tanque: 5000,
                                      stock: 2000
                                  }
                              ]
                          })




