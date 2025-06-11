const { createClient } = require("redis");
const postgres = require("postgres");

const counter = []

const postgresSQL = postgres("postgres://postgres:postgres@localhost:5432/users", {
  host: "localhost",
  port: 5432,
  database: "users",
  username: "postgres",
  password: "postgres",
});

const getUsersPostgres = async(user_id) => {
    const user = await postgresSQL`
        select * from users u
        inner join roles r on u.role_id = r.rol_id
        inner join roles_permissions rp on r.rol_id = rp.role_id
        inner join permissions p on p.permission_id = rp.permission_id
        where u.user_id = ${user_id}
    `
    return user
}

const redis = createClient({
  url: "redis://:eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81@localhost:6379",
});

redis.connect().catch(console.error);

const USER_KEY = "user:";


const getUserCache = async (key) => {
  const cached = await redis.get(key);
  if (cached) {
    return JSON.parse(cached);
  }
  return null;
};

const setUserCache = async (key, data) => {
  await redis.setEx(key, 300, JSON.stringify(data));
};

const getUser = async (id) => {
    
    const userId = `User ${id}`
    if (!counter[userId]) {
        counter[userId] = 0;
    }

    counter[userId]++;

  const redisKey = `${USER_KEY}${id}`;
  const cachedData = await getUserCache(redisKey);
  if(cachedData) {
    console.log('From Redis', cachedData);
    return cachedData;
  }

  const response = await getUsersPostgres(id);
  console.log(response);
  setUserCache(redisKey, response);
  return response;
}


const getUserRequest = async () => {
    await getUser(1);
    await getUser(1);
    console.log(counter)
}

getUserRequest()

