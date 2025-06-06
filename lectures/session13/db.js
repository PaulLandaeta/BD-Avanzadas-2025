import postgres from 'postgres';

const sqlLaPaz = postgres('postgres://postgres:masterpass@localhost:5432/postgres', {
  host : 'localhost',            // Postgres ip address[s] or domain name[s]
  port : 5432,          // Postgres server port[s]
  database : 'postgres',            // Name of database to connect to
  username : 'postgres',            // Username of database user
  password : 'masterpass',            // Password of database user
});

const sqlSantaCruz = postgres('postgres://postgres:slavepass@localhost:5433/postgres', {
  host : 'localhost',            // Postgres ip address[s] or domain name[s]
  port : 5433,          // Postgres server port[s]
  database : 'postgres',            // Name of database to connect to
  username : 'postgres',            // Username of database user
  password : 'slavepass',            // Password of database user
});

const getStudents = async () => {
  const students = await sqlLaPaz`SELECT nombre FROM student`;
  console.log(students, 'Students from DB Master');
}

const getStudentsSlave = async () => {
  const students = await sqlSantaCruz`SELECT nombre FROM student`;
  console.log(students, 'Students from DB Slave');
}

const LA_PAZ = 'LP';
const SANTA_CRUZ = 'SC';

const insertData = async (data) => {
  if(data.city === LA_PAZ) {
    await sqlLaPaz`insert into student (id, name) values (${data.id}, ${data.name})`;
  } else if (data.city === SANTA_CRUZ) {
    await sqlSantaCruz`insert into student (id, name) values (${data.id}, ${data.name})`;
  } else {
    // HASH (id) data.id ya fue hasheado
    const bd = data.id % 2;
    if (bd === 0) {
      await sqlLaPaz`insert into student (id, name) values (${data.id}, ${data.name})`;
    } else {
      await sqlSantaCruz`insert into student (id, name) values (${data.id}, ${data.name})`;
    }
  }
}

const ernesto = { // Este debe ir a la base de datos de La Paz
  id: 1,
  name: 'Ernesto',
  city: LA_PAZ
}

const luis = {    // Este debe ir a la base de datos de Santa Cruz
  id: 2,
  name: 'Luis',
  city: SANTA_CRUZ
}

const miguel = {
  id: 4,
  name: 'Miguel',
  city: 'LP'
}

insertData(ernesto);
insertData(luis);
insertData(miguel);

getStudents();
getStudentsSlave();