# Sesion 19
Proponemos un escenario de librería en línea con dos colecciones principales:
libros
```
{
  _id: ObjectId,       
  titulo: String,      
  autorId: ObjectId,   
  categorias: [String],
  etiquetas: [String], 
  precio: Number,      
  stock: Number        
}
```
autores

```
{
  _id: ObjectId, 
  nombre: String,
  nacionalidad: String,
  nacimiento: Date
}
```
ventas
```
{
  _id: ObjectId,
  libroId: Objec
  cliente: String,
  cantidad: Number,
  total: Number,
  fecha: Date,
  estado: String
}
```

### Consultas 
- Encuentra todos los libros que tengan todas las etiquetas ["bestseller","nuevo"].
- Suponiendo que libros.categorias fuese un array de objetos con { code, label }, busca aquellos que tengan al menos un elemento donde code: "AV" y label: "Aventura".
- Lista los libros que tengan exactamente 3 categorías.
- Añade la etiqueta "oferta" al libro con un _id dado.
- Añade dos nuevas etiquetas ["edición especial","coleccionable"] usando $each.
- Elimina la etiqueta "bestseller" de un libro.
- Asegura que la etiqueta "exclusivo" se agregue solo si no existía
- Elimina el último elemento del array etiquetas.
- Agrupa las ventas por libroId y calcula la suma total vendida (sumTotal).
- Agrupa los libros por autorId y cuenta cuántos títulos tiene cada autor (totalLibros).
- Sobre los libros, agrúpalos en rangos de precio:
  - Hasta $10 → "Barato"
  - Hasta $20 → "Medio"
  - Resto → "Alto"
  Y en cada grupo, suma los precios.
- En la colección ventas, proyecta un campo totalConImpuesto que multiplique total por 1.16 (iva 16%).
- Descompone el array categorias de libros para procesar cada categoría por separado.