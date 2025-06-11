const postgres = require('postgres')
const { createClient } = require('redis')
const jwt = require('jsonwebtoken');

const SECRET = 'defaultsecret';
const EXPIRES_IN = '5m';

const generateToken = (payload) => {
  return jwt.sign(payload, SECRET, { expiresIn: EXPIRES_IN });
};



const postgresClient = postgres("postgres://user:password@localhost:5432/postgres", {
  host: "localhost",
  port: 5432,
  database: "usuarios",
  username: "postgres",
  password: "postgres",
});

const getUserInfotDB = async (id) => {
  const userInfo = await postgresClient` 
    select get_user_info(${id})
  `;
  const data = {
    user: userInfo,

  }
  return userInfo;
};

const redisClient = createClient({
  url: "redis://:redis@localhost:6379",
});

redisClient.connect().catch(console.error);


const USER_KEY = "user:";
const getUserCache = async (key) => {
  const cached = await redisClient.get(key);
  if (cached) {
    return JSON.parse(cached);
  }
  return null;
};

const setUserCache = async (key, data) => {
  await redisClient.setEx(key, 3600, JSON.stringify(data));
};


const getUserInfo = async (id) => {
  const redisKey = `${USER_KEY}${id}`;
  const cachedData = await getUserCache(redisKey);
  const token = generateToken({ user_id: id });
  if(cachedData) {
    console.log('From Redis', cachedData);
    cachedData.count = (cachedData.count || 0) + 1;
    setUserCache(redisKey, cachedData)
    return {...cachedData, token};
  }
  const response = await getUserInfotDB(id);
  const userCount = {...response, count: 1}
  setUserCache(redisKey, userCount);
  return {...userCount, token};
}

getUserInfo(2)