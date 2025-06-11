const { createClient } = require("redis");
const postgres = require("postgres");

const sql = postgres("postgres://user:password@localhost:5432/postgres", {
  host: "localhost",
  port: 5432,
  database: "postgres",
  username: "user",
  password: "password",
});

const client = createClient({
  url: "redis://:eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81@localhost:6379",
});

client.connect().catch(console.error);

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

const incrementUserCounter = async (id) => {
  await client.incr(`user:${id}:counter`);
};

const getUserDB = async (id) => {
  const result = await sql`
    SELECT 
      u.name, 
      u.email, 
      u.city,
      json_agg(DISTINCT r.name) AS roles,
      json_agg(DISTINCT p.name) AS permissions
    FROM users u
    LEFT JOIN roles r ON r.id = u.role_id
    LEFT JOIN role_permissions rp ON rp.role_id = r.id
    LEFT JOIN permissions p ON p.id = rp.permission_id
    WHERE u.id = ${id}
    GROUP BY u.id, u.name, u.email, u.city
  `;
  return result[0] || null;
};

const getUser = async (id) => {
  const redisKey = `${USER_KEY}${id}`;

  await incrementUserCounter(id);

  console.log("Prueba",id);

  const cachedUser = await getUserCache(redisKey);
  if (cachedUser) {
    console.log("User from Redis:", cachedUser);
    return cachedUser;
  }

  const user = await getUserDB(id);
  if (!user) {
    console.log("User not found in DB");
    return null;
  }

  await setUserCache(redisKey, user);
  return user;
};

getUser(2);
