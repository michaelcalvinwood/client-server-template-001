require("dotenv").config();
const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);
const path = require('path');

const { SERVER_IP } = process.env;

if (!SERVER_IP) {
  console.error('SERVER_IP environment variable is not set');
  process.exit(1);
}

async function configureServer() {
  try {
    // Create config directory and set it up
    console.log('Creating and setting up config directory...');
    await execAsync(`ssh root@${SERVER_IP} 'mkdir -p /root/config'`);

    // Sync configuration files
    console.log('Syncing configuration files...');
    const configPath = path.join(__dirname, 'configurationFiles');
    await execAsync(`rsync -av ${configPath}/ root@${SERVER_IP}:/root/config/`);

    // Make scripts executable and run config.sh
    console.log('Making scripts executable and running config.sh...');
    await execAsync(`ssh root@${SERVER_IP} 'cd /root/config && chmod +x *.sh && ./config.sh'`);

    console.log('Server configuration completed successfully');
  } catch (error) {
    console.error('Error during server configuration:', error.message);
    process.exit(1);
  }
}

configureServer();
