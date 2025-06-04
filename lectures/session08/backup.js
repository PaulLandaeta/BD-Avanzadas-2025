const cron = require('cron');
const { exec } = require('child_process');

const job = new cron.CronJob(
	'*/1 * * * *', 
	function () {
		console.log('You will backup every minute');
        const dockerUser = 'postgres';
        const dockerContainer = 'bdavanzada-postgres';
        const DBUser = 'paul';
        const database = 'dvdrental';
        const folder = '/tmp';
        const currentDate = new Date();
        const fileName = `backup_${currentDate.toISOString().slice(0, 10)}.dump`;
        const backupCommand = `docker exec -u ${dockerUser} ${dockerContainer} \
            pg_dump -U ${DBUser} -F c -d ${database} -f /tmp/${fileName}`

        const copyCommand = `docker cp ${dockerContainer}:/tmp/${fileName} ./backups/${fileName}`;
        exec(backupCommand, (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing command: ${error.message}`);
                return;
            }
            exec(copyCommand, (copyError, copyStdout, copyStderr) => {
                if (copyError) {
                    console.error(`Error copying file: ${copyError.message}`);
                    return;
                }
                console.log(`File copied successfully: ${copyStdout}`);
            });
            console.log(`Backup successful: ${stdout}`);
        });
	}, 
	true,
);

job.start();
console.log('Cron job started. It will log a message every second.');