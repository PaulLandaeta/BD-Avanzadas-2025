const cron = require('cron');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const cleanupJob = new cron.CronJob(
  '0 0 */2 * *',
  function () {
    console.log('Ejecutando limpieza de archivos antiguos...', new Date().toISOString());
    
    const backupsDir = path.join(__dirname, '../','backups');
    const now = Date.now();
    const retentionPeriod = 2 * 24 * 60 * 60 * 1000;

    let files;
    try {
      files = fs.readdirSync(backupsDir);
    } catch (err) {
      console.error(`No se puede leer el directorio de backups: ${err.message}`);
      return;
    }

    files.forEach((file) => {
      const filePath = path.join(backupsDir, file);

      if (!file.endsWith('.dump')) return;

      let stats;
      try {
        stats = fs.statSync(filePath);
      } catch (err) {
        console.error(`Error al obtener stats de ${file}: ${err.message}`);
        return;
      }

      const fileAge = now - stats.mtimeMs;
      if (fileAge > retentionPeriod) {
        try {
          fs.unlinkSync(filePath);
          console.log(`Archivo eliminado ( > 2 días ): ${file}`);
        } catch (unlinkErr) {
          console.error(`Error al eliminar ${file}: ${unlinkErr.message}`);
        }
      }
    });

    console.log('Limpieza de archivos antiguos finalizada.');
  },
  null,
  true
);

cleanupJob.start();
console.log('Cleanup cron job iniciado (cada 2 días a medianoche).');
