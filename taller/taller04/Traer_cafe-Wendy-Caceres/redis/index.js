const { createClient } = require("redis");
const postgres = require("postgres");

const sql = postgres("postgres://postgres:postgres@localhost:5432/users", {
  host: "localhost",
  port: 5432,
  database: "users",
  username: "postgres",
  password: "postgres",
});

const redis = createClient({
  url: "redis://:eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81@localhost:6379",
});

redis.connect().catch((err) => console.error("Redis connection error:", err));

const USER_KEY = "user:";

const getUserCache = async (key) => {
  const cached = await redis.get(key);
  return cached ? JSON.parse(cached) : null;
};

const setUserCache = async (key, data) => {
  await redis.setEx(key, 300, JSON.stringify(data));
};

const incrementUserCounter = async (id) => {
  const counterKey = `user:${id}:counter`;
  const count = await redis.incr(counterKey);
  return count;
};

const getUserDB = async (id) => {
  const result = await sql`
    SELECT 
      u.user_id, 
      u.name, 
      u.email, 
      u.city,
      json_agg(DISTINCT r.name) AS roles,
      json_agg(DISTINCT p.name) AS permissions
    FROM users u
    LEFT JOIN roles r ON r.rol_id = u.role_id
    LEFT JOIN roles_permissions rp ON rp.role_id = r.rol_id
    LEFT JOIN permissions p ON p.permission_id = rp.permission_id
    WHERE u.user_id = ${id}
    GROUP BY u.user_id, u.name, u.email, u.city
  `;
  return result[0] || null;
};

const getUser = async (id) => {
  const redisKey = `${USER_KEY}${id}`;
  const requestCount = await incrementUserCounter(id);
  const cachedUser = await getUserCache(redisKey);
  if (cachedUser) {
    console.log(`User ${id} from Redis (Request #${requestCount}):`, cachedUser);
    return cachedUser;
  }

  const user = await getUserDB(id);
  if (!user) {
    console.log(`User ${id} not found in DB (Request #${requestCount})`);
    return null;
  }

  await setUserCache(redisKey, user);
  console.log(`User ${id} from DB (Request #${requestCount}):`, user);
  return user;
};

const getUserRequest = async () => {
  await getUser(1);
  await getUser(1);
  const count = await redis.get(`user:1:counter`);
  console.log(`Total requests for User 1: ${count}`);
};

getUserRequest();