import { createClient } from 'redis';
import postgres from 'postgres';
import dotenv from 'dotenv';
dotenv.config();

const sql = postgres('postgres://postgres:doriax@localhost:5432/postgres', {
  host:     process.env.DB_HOST,
  port:     process.env.DB_PORT,
  database: process.env.DB_NAME,
  username: process.env.DB_USER,
  password: process.env.DB_PASS,
});

const client = createClient({
  url: `redis://:${process.env.REDIS_PASSWORD}@${process.env.REDIS_HOST}:${process.env.REDIS_PORT}`
});
client.connect().catch(console.error);

const USER_KEY  = 'user:';
const COUNT_KEY = 'user:count:';
const TTL_SEC   = 5 * 60;

const getUserById = async (id) => {

  const users = await sql`
    SELECT id, name, email, city
    FROM users
    WHERE id = ${id}
  `;
  if (!users.length) return null;

  const roles = await sql`
    SELECT r.id, r.name
    FROM roles r
    JOIN user_roles ur ON ur.role_id = r.id
    WHERE ur.user_id = ${id}
  `;

  const permisos = await sql`
    SELECT p.id, p.name
    FROM permisos p
    JOIN user_permisos up ON up.permiso_id = p.id
    WHERE up.user_id = ${id}
  `;

  return {
    ...users[0],
    roles,
    permisos
  };
};

const setUserDB = async ({ name, email, city, roleIds = [], permisoIds = [] }) => {
  
  const inserted = await sql`
    INSERT INTO users (name, email, city)
    VALUES (${name}, ${email}, ${city})
    RETURNING id
  `;
  const userId = inserted[0].id;

  for (const roleId of roleIds) {
    await sql`
      INSERT INTO user_roles (user_id, role_id)
      VALUES (${userId}, ${roleId})
    `;
  }

  for (const permisoId of permisoIds) {
    await sql`
      INSERT INTO user_permisos (user_id, permiso_id)
      VALUES (${userId}, ${permisoId})
    `;
  }

  return { ok: true, userId };
};

const getUserCache = async (key) => {
  const v = await client.get(key);
  return v ? JSON.parse(v) : null;
};

const setUserCache = async (key, data) => {
  await client.setEx(key, TTL_SEC, JSON.stringify(data));
};

const incrUserCount = async (id) => {
  const countKey = COUNT_KEY + id;
  const count = await client.incr(countKey);

  if (count === 1) {
    await client.expire(countKey, TTL_SEC);
  }
  return count;
};

const getUser = async (id) => {
  const redisKey = USER_KEY + id;

  const cached = await getUserCache(redisKey);
  if (cached) {
    const timesRequested = await incrUserCount(id);
    console.log('⚡ From Redis:', cached);
    return { user: cached, timesRequested };
  }

  const user = await getUserById(id);
  if (!user) {
    console.log(`User ${id} not found`);
    return null;
  }

  await setUserCache(redisKey, user);
  await client.setEx(COUNT_KEY + id, TTL_SEC, '1');

  console.log('✅ From DB:', user);
  return { user, timesRequested: 1 };
};

const llenarDatos = async () => {
  
  const roleNames   = ['admin', 'user'];
  const permisoNames= ['read','write','update','delete','manage'];

  for (const name of roleNames) {
    await sql`INSERT INTO roles (name) VALUES (${name})`;
  }

  for (const name of permisoNames) {
    await sql`INSERT INTO permisos (name) VALUES (${name})`;
  }

  const dbRoles   = await sql`SELECT id, name FROM roles`;
  const dbPermisos   = await sql`SELECT id, name FROM permisos`;
  const roleMap   = new Map(dbRoles.map(r => [r.name, r.id]));
  const permisoMap= new Map(dbPermisos.map(p => [p.name, p.id]));

  const rolCombinaciones = [
    ['admin'],
    ['user'],
    ['admin','user']
  ];

  const permisoCombinaciones = [
    ['read'],
    ['write'],
    ['update'],
    ['delete'],
    ['manage'],
    ['read','write'],
    ['read','update','manage']
  ];

  const cities = ['La Paz','Cochabamba','Santa Cruz','Sucre','Oruro'];

  for (let i = 0; i < 10; i++) {
    const idx        = i + 1;
    const name       = `Usuario${idx}`;
    const email      = `usuario${idx}@ejemplo.com`;
    const city       = cities[i % cities.length];
    const rolesNames = rolCombinaciones[i % rolCombinaciones.length];
    const permsNames = permisoCombinaciones[i % permisoCombinaciones.length];

    const roleIds    = rolesNames.map(n => roleMap.get(n));
    const permisoIds = permsNames.map(n => permisoMap.get(n));

    const userId = await setUserDB({
      name, email, city,
      roleIds, permisoIds
    });

    console.log(`- Usuario ${userId}: roles=[${rolesNames.join(',')}], permisos=[${permsNames.join(',')}]`);
  }
};

(async () => {
  for (const id of [1, 2, 3]) {
    const res1 = await getUser(id);
    console.log(`Primera llamada a getUser(${id}):`, res1);

    const res2 = await getUser(id);
    console.log(`Segunda llamada a getUser(${id}):`, res2);

    console.log('— Estado Redis directamente:');
    console.log(
      '  user:', await client.get(USER_KEY + id),
      '\n  ttl:', await client.ttl(USER_KEY + id),
      '\n  count:', await client.get(COUNT_KEY + id)
    );
    console.log('\n\n\n');
  }

  await client.quit();
  process.exit(0);
})();
