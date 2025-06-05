const { execSync } = require("child_process");
const path = require("path");
const fs = require("fs");
require("dotenv").config();

const isWindows = process.platform === "win32";
const shellOption = isWindows ? undefined : "/bin/bash";

const DB_SUFFIX = "8";  // Variable que se cambia para poder crear los restore sin 

function restorePostgres() {
  const folder = process.env.PG_BACKUP_FOLDER;
  const latestFile = fs.readdirSync(folder)
    .filter(name => name.endsWith(".dump"))
    .sort()
    .reverse()[0];

  if (!latestFile) return console.error("No PostgreSQL backup found.");

  const container = process.env.PG_CONTAINER;
  const user = process.env.PG_USER;
  const tempFolder = process.env.PG_TEMP_FOLDER;
  const baseName = process.env.PG_DB;
  const newDb = `${DB_SUFFIX}hash_${baseName}`;
  const localPath = path.join(folder, latestFile);
  const containerPath = path.posix.join(tempFolder, latestFile);

  console.log(`BAckup de conteiner: ${containerPath}`);
  execSync(`docker cp "${localPath}" ${container}:${containerPath}`, {
    stdio: "inherit", shell: shellOption
  });

  console.log(`Creando base de datos ${newDb}`);
  execSync(`docker exec -u postgres ${container} createdb -U ${user} ${newDb}`, {
    stdio: "inherit", shell: shellOption
  });

  console.log(`Restaurando base de datos: ${newDb}`);
  execSync(`docker exec -u postgres ${container} pg_restore -U ${user} -d ${newDb} ${containerPath}`, {
    stdio: "inherit", shell: shellOption
  });

  console.log("PostgreSQL restaurado en:", newDb);
}

try {
  restorePostgres();
} catch (err) {
  console.error("Error al restaurar:", err.message);
}