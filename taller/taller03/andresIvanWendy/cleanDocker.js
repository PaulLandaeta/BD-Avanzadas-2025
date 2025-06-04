const cron = require("cron");
const { exec } = require("child_process");
const dotenv = require("dotenv");

dotenv.config();

const dockerUser = process.env.DOCKER_USER || "postgres";
const dockerContainer = process.env.DOCKER_CONTAINER || "bd-avanzada-postgres";
const folder = process.env.BACKUP_FOLDER || "/tmp";

const job = new cron.CronJob("0 0 */2 * *", function () {
  console.log("Iniciando limpieza de backups...");

  const cleanupCommand = `docker exec -u root ${dockerContainer} find ${folder} -type f -mmin +4 -delete`;

  exec(cleanupCommand, (error, stdout, stderr) => {
    if (error) {
      console.error(`❌ Error al ejecutar la limpieza: ${error.message}`);
      return;
    }
    if (stderr) {
      console.error(`⚠️ Salida de error: ${stderr}`);
      return;
    }
    console.log("✅ Backups antiguos eliminados correctamente.");
  });
});

// Iniciar cron job
job.start();
console.log(
  "Cron de limpieza iniciado. Se ejecutará cada 2 días a las 3:00 AM."
);
