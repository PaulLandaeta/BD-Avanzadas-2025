const { createClient } = require("redis");
const postgres = require("postgres");

const sql = postgres("postgres://user:password@localhost:5432/postgres", {
  host: "localhost",
  port: 5432,
  database: "postgres",
  username: "user",
  password: "password",
});

const getStudentDB = async (id) => {
  const students = await sql` 
    select *
    from students
    where id = ${id}
  `;
  console.log(students);
  return students;
};

const client = createClient({
  url: "redis://:eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81@localhost:6379",
});

client.connect().catch(console.error);

// name:id
const STUDENT_KEY = "student:";
const getStudentCache = async (key) => {
  const cached = await client.get(key);
  if (cached) {
    return JSON.parse(cached);
  }
  return null;
};

const setStudentCache = async (key, data) => {
  await client.setEx(key, 3600, JSON.stringify(data));
};

// setStudentCache(`STUDENT_KEY${2}`, { id: 2, name: 'paul'});

const getStudent = async (id) => {
  const redisKey = `STUDENT_KEY${id}`;
  const cachedData = await getStudentCache(redisKey);
  if(cachedData) {
    console.log('From Redis', cachedData);
    return cachedData;
  }

  const response = await getStudentDB(id);
  console.log(response);
  setStudentCache(redisKey, response);
  return response;
}

getStudent(1);