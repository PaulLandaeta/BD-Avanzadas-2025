import { createClient } from "redis";
import postgres from "postgres";

const FIVE_MIN = 5;
const USER2_KEY = id => `users:${id}`;
const HITS_KEY = id => `users:${id}:hits`;

async function getUser2(id) {
  const hits = await client.incr(HITS_KEY(id));
  if (hits === 1) await client.expire(HITS_KEY(id), FIVE_MIN);

  const cached = await client.get(USER2_KEY(id));
  if (cached) return JSON.parse(cached);

  const [user] = await sql`SELECT * FROM users WHERE id = ${id}`;

  await client.setEx(USER2_KEY(id), FIVE_MIN, JSON.stringify(user));
  return user;
}

const sql = postgres("postgres://user:password@localhost:5432/postgres", {
    host: "localhost",
  port: 5432,
  database: "taller4",
  username: "thompson",
  password: "thompson",
});

const getUserDB = async (id) => {
  const students = await sql` 
    select *
    from users
    where id = ${id}
  `;
  console.log(students);
  return students;
};

const client = createClient({
  url: "redis://:root123@localhost:6379",
});

client.connect().catch(console.error);


const USER_KEY = "users:";
const getUserCache = async (key) => {
  const cached = await client.get(key);
  if (cached) {
    return JSON.parse(cached);
  }
  return null;
};

const setUserCache = async (key, data) => {
  await client.setEx(key, 3600, JSON.stringify(data));
};

const getUser = async (id) => {
  const redisKey = `${USER_KEY}${id}`;
  const cachedData = await getUserCache(redisKey);
  if(cachedData) {
    console.log('From Redis', cachedData);
    return cachedData;
  }

  const response = await getUserDB(id);
  console.log(response);
  setUserCache(redisKey, response);
  return response;
}

const setUserData = async (data) => {
  const { id, name, email, city, permisos, role } = data;
  const [roleRow] = await sql`
    INSERT INTO roles (name)
    VALUES (${role})
    ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
    RETURNING id;
  `;
  const roleId = roleRow.id;
  const permisoIds = [];
  for (const permisoName of permisos) {
    const [permisoRow] = await sql`
      INSERT INTO permisos (name)
      VALUES (${permisoName})
      ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
      RETURNING id;
    `;
    permisoIds.push(permisoRow.id);
  }
  await sql`
    DELETE FROM roles_permisos WHERE role_id = ${roleId};
  `;
  for (const permisoId of permisoIds) {
    await sql`
      INSERT INTO roles_permisos (role_id, permiso_id)
      VALUES (${roleId}, ${permisoId})
      ON CONFLICT DO NOTHING;
    `;
  }
  await sql`
    INSERT INTO users (id, name, email, city, role_id)
    VALUES (${id}, ${name}, ${email}, ${city}, ${roleId})
    ON CONFLICT (id) DO UPDATE SET
      name = EXCLUDED.name,
      email = EXCLUDED.email,
      city = EXCLUDED.city,
      role_id = EXCLUDED.role_id;
  `;
  return { ok: true };
};

const getTodoUser = async (id) => {
    const result = await sql`
    SELECT 
    u.id,
    u.name,
    u.email,
    u.city,
    r.name AS role,
    COALESCE(json_agg(p.name) FILTER (WHERE p.name IS NOT NULL), '[]') AS permisos
    FROM users u
    JOIN roles r ON u.role_id = r.id
    LEFT JOIN roles_permisos rp ON r.id = rp.role_id
    LEFT JOIN permisos p ON rp.permiso_id = p.id
    WHERE u.id = ${id}
    GROUP BY u.id, r.name;
    `;
    return result[0];
};


const setUser = async (data) => {
  const response = await setUserData(data);
  if (response.ok) {
    const userFull = await getTodoUser(data.id);
    const redisKey = `${USER_KEY}${data.id}`;
    await setUserCache(redisKey, userFull);
  }
};

getUser(2);
getUser2(2);
// setUser({
//   id: 5,
//   name: 'user11',
//   email: 'email11@example.com',
//   city: 'Lima11',
//   permisos: ['profe', 'jefe'],
//   role: 'userPro2',
// });