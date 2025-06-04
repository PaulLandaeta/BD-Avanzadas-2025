const cron = require("cron");
const { exec } = require("child_process");
const dotenv = require("dotenv");

dotenv.config();
console.log("Restoring backup");
const dockerUser = process.env.DOCKER_USER || "postgres";
const dockerContainer = process.env.DOCKER_CONTAINER || "bd-avanzada-postgres";
const user = process.env.DB_USER || "nameUser";
const folder = process.env.BACKUP_FOLDER || "/tmp";
const restore_db = process.env.RESTORE_DB || "restored_dvdrental";
const restoreCommand = `docker exec -u ${dockerUser} ${dockerContainer} pg_restore --clean -U ${user} -d ${restore_db} ${folder}/`;

const latestBackupCommand = `docker exec -u ${dockerUser} ${dockerContainer} sh -c "ls -t ${folder} | head -n 1"`;
exec(latestBackupCommand, (error, stdout, stderr) => {
  if (error) {
    console.error(`Error executing command: ${error.message}`);
    return;
  }
  if (stderr) {
    console.error(`Error output: ${stderr}`);
    return;
  }
  const latestBackup = stdout;
  console.log(`📁 Respaldo más reciente encontrado: ${latestBackup}`);
  exec(`${restoreCommand}${latestBackup}`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error executing restore command: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`Error output during restore: ${stderr}`);
      return;
    }
    console.log("✅ Base de datos restaurada correctamente.");
  });
});
