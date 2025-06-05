const { exec } = require('child_process');
const path = require('path');
const backupDir = path.join(__dirname, 'backups');

const command = `find "${backupDir}" -type f -name "*.dump" -mtime +2 -exec rm -v {} \\;`;

exec(command, (err, stdout, stderr) => {
  if (err) {
    console.error(`Error al ejecutar find: ${err.message}`);
    return;
  }
  if (stderr) {
    console.error(`stderr: ${stderr}`);
  }
  if (stdout.trim().length) {
    console.log('Archivos eliminados:\n', stdout);
  } else {
    console.log('No había archivos de más de 2 días para eliminar.');
  }
});
