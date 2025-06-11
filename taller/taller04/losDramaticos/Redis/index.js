const { createClient } = require("redis");
const postgres = require("postgres");

const client = createClient({
  url: "redis://:eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81@localhost:6379",
});

client.connect().catch(console.error);
const sql = postgres("postgres://user:password@localhost:5432/postgres", {
  host: "localhost",
  port: 5432,
  database: "postgres",
  username: "user",
  password: "password",
});

const getUserDB = async (id) => {
  const users = await sql` 
    select u.name, u.email,u.city, r.name as userType, json_agg(p.name) AS permisos
    from users u
    inner join role r on u.role_id = r.id
    inner join public.role_permission rp on r.id = rp.role_id
    inner join public.permission p on p.id = rp.permission_id
    where u.id = ${id}
group by u.name, u.email, u.city, r.name
  `;
  return users[0];
};

// name:id
const USER_KEY = "user:";
const getUserCache = async (key) => {
  const cached = await client.get(key);
  if (cached) {
    return JSON.parse(cached);
  }
  return null;
};

const setUserCache = async (key, data) => {
  await client.setEx(key, 300, JSON.stringify(data));
};


const getUser = async (id) => {
  const redisKey = `USER_KEY${id}`;
  const countKey = `user:${id}:count`;

  await client.incr(countKey);

  const cachedData = await getUserCache(redisKey);
  const ttl = await client.ttl(redisKey);
  if(cachedData) {
    console.log('From Redis', cachedData);
    console.log(`TTL restante: ${ttl} segundos`);
    const count = await client.get(countKey);
    console.log(`Accesos a user ${id}: ${count} veces`);
    return cachedData;
  }

  const response = await getUserDB(id);
  console.log(response);
  setUserCache(redisKey, response);
  const count = await client.get(countKey);
  console.log(`Accesos a user ${id}: ${count} veces`);
  return response;
}

getUser(1);
