const cron = require('cron');
const { exec } = require('child_process');
require('dotenv').config();

const job = new cron.CronJob(
	'*/5 * * * *',
	function () {
		console.log('You will see this message every second');
        const dockerUser = 'postgres';
        const dockerContainer = 'bdavanzada-postgres';
        const user = process.env.DB_USER;
        const database = process.env.DB_NAME;
        const folder = process.env.BACKUP_FOLDER;
        const currentDate = new Date();
        const fileName = `backup_${currentDate.toISOString().slice(0, 10)}.dump`;
        const backupCommand = `docker exec -u ${dockerUser} ${dockerContainer} pg_dump -U ${user} -F c -d ${database} -f /tmp/${fileName}`;
        const copyCommand = `docker cp ${dockerContainer}:/tmp/${fileName} ./backup/${fileName}`;
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

const cleanupJob = new cron.CronJob(
    '0 0 */2 * *',
    async function () {
        console.log('Starting cleanup of old backups');
        const folder = './backup';
        try {
            const files = await fs.readdir(folder);
            const twoDaysAgo = new Date();
            twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);

            for (const file of files) {
                if (file.endsWith('.dump')) {
                    const filePath = `${folder}/${file}`;
                    const stats = await fs.stat(filePath);
                    if (stats.mtime < twoDaysAgo) {
                        await fs.unlink(filePath);
                        console.log(`Deleted old backup: ${file}`);
                    }
                }
            }
            console.log('Cleanup completed');
        } catch (error) {
            console.error(`Error during cleanup: ${error.message}`);
        }
    },
    null,
    true
);


job.start();
cleanupJob.start();
console.log('Cron job started. It will log a message every second.');