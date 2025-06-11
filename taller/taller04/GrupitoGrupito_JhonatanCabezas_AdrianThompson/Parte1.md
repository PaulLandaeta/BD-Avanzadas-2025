Se realizo la augtomatizacion de obtencio y guardado en redis cache, donde se aplica un ttl de 5 min para que este se borre y un contador de cuantas veces se ha solicitado dicho usuario con el id. 

Captura 1 se ve como se esta recibiendo los datos
captura 2 se ve como se esta guardando en redis cache
captura 3 se ve como se esta consultando el usuario y el contador de veces que se ha solicitado
captura 4 se ve como se esta eliminando el usuario de redis cache
captura 5 se ve como se esta actualizando el usuario en redis cache