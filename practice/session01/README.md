# Monto total pagado por cada cliente
```
SELECT 
  c.customer_id,
  c.first_name AS nombre_completo,
  SUM(p.amount) AS total_pagado
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_pagado DESC;
```

# Clientes que han pagado más de $200

```
SELECT 
  c.customer_id,
  c.first_name,
  SUM(p.amount) AS total_pagado
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(p.amount) > 200
ORDER BY total_pagado DESC;
```
# Cantidad de películas por categoría y promedio de duración
```
select c."name", avg(f.rental_duration), count(*)
from film f
         inner join film_category fc
                    on fc.film_id = f.film_id
         inner join category c
                    on c.category_id = fc.category_id
group by c."name";
```
# JSON de películas por categoría
```
```

