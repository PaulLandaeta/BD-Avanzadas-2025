const { createClient } = require("redis");
const postgres = require("postgres");
const redisAccessCount = {};

const sql = postgres("postgres://user:password@localhost:5432/postgres", {
  host: "localhost",
  port: 5432,
  database: "postgres",
  username: "nameUser",
  password: "passwordUser",
});

const getStudentDB = async (id) => {
  const students = await sql` 
  select u.username, u.email, u.city, r.name as role, json_agg(p.name) as permissions
  from users u
  join roles r on u.role_id = r.id
  join role_permissions rp on r.id = rp.role_id
  join permissions p on rp.permission_id = p.id
  where u.id = ${id}
  group by u.id, r.id
  `;
  console.log(students);
  return students;
};

const client = createClient({
  url: "redis://localhost:6379",
});

client.connect().catch(console.error);

const STUDENT_KEY = "student:";
const getStudentCache = async (key) => {
  redisAccessCount[key] = (redisAccessCount[key] || 0) + 1;

  const cached = await client.get(key);
  if (cached) {
    return JSON.parse(cached);
  }
  return null;
};

const setStudentCache = async (key, data) => {
  await client.setEx(key, 60 * 5, JSON.stringify(data));
};

const getStudent = async (id) => {
  const redisKey = `${STUDENT_KEY}${id}`;
  const cachedData = await getStudentCache(redisKey);
  if (cachedData) {
    console.log(cachedData);
    console.log(
      `Redis accessed ${redisAccessCount[redisKey]} times for key: ${redisKey}`
    );
    return cachedData;
  }

  const response = await getStudentDB(id);
  console.log("From db");
  console.log(response);
  setStudentCache(redisKey, response);
  return response;
};


getStudent(1);
getStudent(2);
getStudent(1);

console.log(redisAccessCount)