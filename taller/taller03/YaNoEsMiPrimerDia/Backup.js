const cron = require('cron');
const { exec } = require('child_process');

const job = new cron.CronJob(
  '*/1 * * * *',
  function () {
    console.log('You will see this message every second');
    
    const dockerUser = 'postgres';
    const dockerContainer = 'bdavanzada-postgres';
    const dbUser = 'dorianUser'; // Replace with your actual database user
    const database = 'dvdrental';
    const folder = '/tmp';
    const currentDate = new Date();
    const fileName = `backup_${currentDate.toISOString().slice(0, 10)}.dump`;
    const backupCommand = `docker exec -u ${dockerUser} ${dockerContainer} pg_dump -U ${dbUser} -F c -d ${database} -f ${folder}/${fileName}`;
    const copyCommand = `docker cp ${dockerContainer}:${folder}/${fileName} ./backups/${fileName}`;
    
    exec(backupCommand, (error, stdout, stderr) => {
      if (error) {
        console.error(`Error executing backup command: ${error.message}`);
        return;
      }
      if (stderr) {
        console.error(`Backup stderr: ${stderr}`);
        return;
      }
      console.log(`Backup stdout: ${stdout}`);
      
      exec(copyCommand, (copyError, copyStdout, copyStderr) => {
        if (copyError) {
          console.error(`Error copying backup file: ${copyError.message}`);
          return;
        }
        if (copyStderr) {
          console.error(`Copy stderr: ${copyStderr}`);
          return;
        }
        console.log(`Backup file copied successfully: ${copyStdout}`);
      });
    });
  },
  true,
);

job.start();
console.log('Cron job started. It will log a message every minute.');