const  postgres = require('postgres');

const sqlLaPaz = postgres('postgres://postgress:masterpass@localhost:5432/postgres', {
  host                 : 'localhost',
  port                 : 5432,
  database             : 'postgres',
  username             : 'postgres',
  password             : 'masterpass',
})

const sqlSantaCruz = postgres('postgres://postgress:masterpass@localhost:5432/postgres', {
  host                 : 'localhost',
  port                 : 5433,
  database             : 'postgres',
  username             : 'postgres',
  password             : 'slavepass',
})


const getStudent = async () => {
const students = await sqlLaPaz`
    select
        name
    from student
    `;
    console.log(students);
};

const getStudentSlave = async () => {
const students = await sqlSantaCruz`
    select
        name
    from student
    `;
    console.log(students);
};



getStudent();
getStudentSlave();


const LA_PAZ = 'LP';
const SANTA_CRUZ = 'SC';

const insertData = async (data) => {
    if(data.city === LA_PAZ){
        await sqlLaPaz `insert into student(id, name, lastname, semester) values(${data.id}, ${data.name}, ${data.lastname}, ${data.semester})`
    } else if (data.city === SANTA_CRUZ) {
        await sqlSantaCruz `insert into student(id, name, lastname, semester) values(${data.id}, ${data.name}, ${data.lastname}, ${data.semester})`
    } else {
         const bd = data.id % 2
        if (bd === 0){
            await sqlLaPaz `insert into student(id, name, lastname, semester) values(${data.id}, ${data.name}, ${data.lastname}, ${data.semester})`
        } else {
            await sqlSantaCruz `insert into student(id, name, lastname, semester) values(${data.id}, ${data.name}, ${data.lastname}, ${data.semester})`
        }
    }
}

const miguel = {
    city: 'LP',
    id: 4,
    name: 'Miguel',
    lastname: 'Quenta',
    semestre: 7
}

const zein = {
    city: 'SC',
    id: 5,
    name: 'Zein',
    lastname: 'Tonconi',
    semestre: 7
}

const andres = {
    city: 'CBB',
    id: 6,
    name: 'Andres',
    lastname: 'Sanchez',
    semestre: 7
}

insertData(miguel)
insertData(zein)
insertData(andres)