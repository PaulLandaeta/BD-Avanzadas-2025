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

cleanupJob.start();
console.log('Cron job started. It will log a message every second.');