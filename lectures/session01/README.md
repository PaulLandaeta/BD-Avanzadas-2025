****# Total de películas por categoría

```
select c."name", count(*)
    from film f
    inner join film_category fc
on fc.film_id = f.film_id
inner join category c
on c.category_id = fc.category_id
group by c."name";
```

# Total de películas por actor

```
select a.first_name, a.last_name, count(*)
from actor a
    inner join film_actor fa
    on fa.actor_id = a.actor_id
    inner join film f
    on f.film_id = fa.film_id
group by a.first_name, a.last_name 
order by count(*) desc
```

# Total de pagos por cliente

```
select c.first_name, c.last_name, count(*)
from payment p
    inner join customer c
    on c.customer_id = p.customer_id
group by c.first_name, c.last_name
order by count(*) desc
```

# Total recaudado por tienda

```
<!-- con la ayuda de una vista -->
select * from sales_by_store sbs 
```

# Mostrar cada actor con JSON de sus películas
```
```
