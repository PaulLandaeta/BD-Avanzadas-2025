const postgres = require("postgres");

const sqlLaPaz = postgres(
  "postgres://postgres:masterpass@localhost:5432/postgres",
  {
    host: "localhost",
    port: 5432,
    database: "postgres",
    username: "postgres",
    password: "masterpass",
  }
);

const sqlSanta= postgres(
  "postgres://postgres:slavepass@localhost:5433/postgres",
  {
    host: "localhost",
    port: 5433,
    database: "postgres",
    username: "postgres",
    password: "slavepass",
  }
);

const getStudent = async () => {
  const students = await sqlLaPaz` 
    select
      name
    from student
  `;
  console.log(students);
};

const getStudentSlave = async () => {
  const students = await sqlSanta` 
    select
      name
    from student
  `;
  console.log(students);
};




const LA_PAZ = 'LP';
const SANTA_CRUZ = 'SC';
const insertData = async (data) => {
    if(data.city === LA_PAZ) {
        await sqlLaPaz`insert into student(id, name) values(${data.id},${data.name})`
    } else if(data.city === SANTA_CRUZ) {
        await sqlSanta`insert into student(id, name) values(${data.id},${data.name})`
    } else {
        // HASH (id) data.id ya fue hasheado
        const bd = data.id % 2;
        if( bd === 0) {
            await sqlLaPaz`insert into student(id, name) values(${data.id},${data.name})`
        } else {
            await sqlSanta`insert into student(id, name) values(${data.id},${data.name})`
        }
    }
}

const ernesto = {
    city:'LP',
    id: 2,
    name: 'ernesto'
}
const luis = {
    city:'SC',
    id: 2,
    name: 'luis'
}
const miguel = {
    city:'CBBA',
    id: 5,
    name: 'miguel'
}

insertData(ernesto);
insertData(luis);
insertData(miguel);




getStudent();
getStudentSlave();