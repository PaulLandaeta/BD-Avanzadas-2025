# Operadores de Arrays en MongoDB

### Operador $all

El operador $all selecciona los documentos donde el valor de un campo array contiene todos los elementos especificados.

```sql
[
  { "_id": 1, "tags": ["electrónica", "hogar", "oferta"] },
  { "_id": 2, "tags": ["deporte", "verano"] },
  { "_id": 3, "tags": ["electrónica", "oferta"] }
]

db.productos.find({ tags: { $all: ["electrónica", "oferta"] } })
```

### Operador $elemMatch

El operador $elemMatch selecciona los documentos si al menos un elemento del array cumple todos los criterios especificados.

```sql
[
  { "_id": 1, "tags": [{ "value": "electrónica", "label": "Electrónica" }, { "value": "hogar", "label": "Hogar" }] },
  { "_id": 2, "tags": [{ "value": "deporte", "label": "Deporte" }, { "value": "verano", "label": "Verano" }] }
]

db.productos.find({ tags: { $elemMatch: { value: "electrónica", label: "Electrónica" } } })
```

### Operador $size

El operador $size selecciona los documentos donde el array tiene un número específico de elementos.

```sql 
[
  { "_id": 1, "tags": ["electrónica", "hogar", "oferta"] },
  { "_id": 2, "tags": ["deporte", "verano"] }
]

db.productos.find({ tags: { $size: 2 } })
```

### Operador $push

El operador $push añade un nuevo elemento al final de un array.

```sql 
{ "_id": 1, "tags": ["electrónica", "hogar"] }
db.productos.updateOne(
  { _id: 1 },
  { $push: { tags: "oferta" } }
)
```

Para poder agregar varios elementos 

```sql 
db.productos.updateOne(
  { _id: 1 },
  { $push: { tags: { $each: ["oferta", "nuevo"] } } }
)
```
### Operador $pull

El operador $pull elimina todos los elementos del array que coinciden con una condición.

```sql 
{ "_id": 1, "tags": ["electrónica", "hogar", "oferta"] }

db.productos.updateOne(
  { _id: 1 },
  { $pull: { tags: "hogar" } }
)
```

Si deseamos eliminar varios elementos del array usaremos el operador in 

```sql
db.productos.updateOne(
  { _id: 1 },
  { $pull: { tags: { $in: ["oferta", "nuevo"] } } }
)
```

### Operador $addToSet

El operador $addToSet añade un nuevo elemento al array solo si no está presente.

```sql
{ "_id": 1, "tags": ["electrónica", "hogar"] }
db.productos.updateOne(
  { _id: 1 },
  { $addToSet: { tags: "hogar" } }
)
```

Si deseamos agregar varios elementos 

```sql
db.productos.updateOne(
  { _id: 1 },
  { $addToSet: { tags: { $each: ["oferta", "nuevo", "exclusivo"] } } }
) 
```


### Operador $pop

El operador $pop elimina el primer o último elemento de un array.

```sql 
{ "_id": 1, "tags": ["electrónica", "hogar", "oferta"] }

db.productos.updateOne(
  { _id: 1 },
  { $pop: { tags: 1 } }  // Para eliminar el primer elemento, usa -1
)
```

// PIPELINE
// Secuencia de pasos 
// [$ match,  ]

### Operador $group de Agregación


Se puede usar $sum, $avg, $max, $min, 
```sql 
db.libros.aggregate([
    {
        $group: {
            _id: '$autor',
            sumPrice: {$sum: "$price"}
        }
    }
])
``` 

hacer un count 
```sql 
db.libros.aggregate([
    {
        $group: {
            _id: '$autor',
            totalLibros: {$sum: 1}
        }
    }
])
```

agrupar por switch 

```js
db.libros.aggregate([
    {
        $group: {
            _id: {
                $switch: {
                    branches: [
                        {case: { $lte:["$price", 5]}, then: "Bajo"},
                        {case: { $lte:["$price", 10]}, then: "Medio"}
                    ],
                    default: "Alto"
                }
            },
           suma: { $sum: "$price" }
        }
    }
])
```

### Operador $sort de Agregación

```js
db.libros.aggregate([
    {
        $sort: {
            price: 1
        }
    }
])
```

### Operador $project de Agregación 

```js
db.collection.aggregate([
  {
    $project: {
      name: 1,
      totalAmount: { $multiply: ["$quantity", "$price"] }
    }
  }
])
```

### Descomoponer $unwind de Agregación 

Descomponer un array por elemento 

```js
db.libros.aggregate([
  { $unwind: "$categorias" }
])
```

### Operador $count de Agregación 

Contar numero de de documentos que cumplan un criterio

```js
db.libros.aggregate([
  { $match: { autor: "Victor" } },
  { $count: "total" }
])
```

```
db.ventas.aggregate([
    {
        $facet: {
            ventasCompletadas: [
                { $match: { estado: "completado" }},
                { $project: { _id: 0, cliente: 1, total: 1 }}
            ],
            ventasPendientes: [
                { $match: { estado: "pendiente" }},
                { $project: { _id: 0, cliente: 1, total: 1 }}
            ]
        }
    }
])
```


```
db.ventas.aggregate([
    {
        $facet: {
            ventasCompletadas: [
                { $match: { estado: "completado" }},
                { $project: { _id: 0, cliente: 1, total: 1 }}
            ],
            ventasPendientes: [
                { $match: { estado: "pendiente" }},
                { $project: { _id: 0, cliente: 1, total: 1 }}
            ]
        }
    }
])
```



db.collection.aggregate([
    {
        $lookup: {
            from: "otraColeccion",
            localField: "campoLocal",
            foreignField: "campoExterno",
            as: "nombreDelCampo"
        }
    }
])



db.libros.aggregate([
    {
        $lookup: {
            from: "autores",
            localField: "autorId",
            foreignField: "_id",
            as: "autorDetalles"
        }
    },
    {
        $unwind: "$autorDetalles"
    },
    {
        $project: {
            _id: 1,
            titulo: 1,
            año: 1,
            "autorDetalles.nombre": 1,
            "autorDetalles.nacionalidad": 1
        }
    }
])


db.libros.aggregate([
    {
        $lookup: {
            from: "autores",
            localField: "autorId",
            foreignField: "_id",
            as: "autorDetalles"
        }
    },
    {
        $unwind: "$autorDetalles"
    },
    {
        $project: {
            _id: 1,
            titulo: 1,
            año: 1,
            "autorDetalles.nombre": 1,
            "autorDetalles.nacionalidad": 1
        }
    }
])

