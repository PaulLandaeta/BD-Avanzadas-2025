const cron = require("cron");
const { exec } = require("child_process");
require("dotenv").config();
const fs = require("fs");

// Crea carpetas de backup si no hay
[
  process.env.PG_BACKUP_FOLDER,
].forEach(
  (dir) => dir && !fs.existsSync(dir) && fs.mkdirSync(dir, { recursive: true })
);

const fecha = () => new Date().toISOString().replace(/[:T]/g, "_").slice(0, 16);

// PostgreSQL Backup
function backupPostgres() {
  const fileName = `backup_dvdrental${fecha()}.dump`;
  const cmd = `docker exec -u postgres ${process.env.PG_CONTAINER} \
pg_dump -U ${process.env.PG_USER} -F c -d ${process.env.PG_DB} -f ${process.env.PG_TEMP_FOLDER}/${fileName}`;

  const cpCmd = `docker cp ${process.env.PG_CONTAINER}:${process.env.PG_TEMP_FOLDER}/${fileName} ${process.env.PG_BACKUP_FOLDER}/${fileName}`;
  exec(cmd, (err) => {
    if (err) return console.error("PG backup error:", err.message);
    exec(cpCmd, (err2) => {
      if (err2) return console.error("PG copy error:", err2.message);
      console.log("PostgreSQL backup done:", fileName);
    });
  });
}

const job = new cron.CronJob("*/1 * * * *", () => {
  console.log("Creando el backup", new Date().toLocaleString());
  backupPostgres();
});
job.start();

console.log("Backup cron job started. Every minute backups will run.");