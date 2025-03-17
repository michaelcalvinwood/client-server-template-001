require("dotenv").config();
const { SERVER_DOMAIN } = process.env;
/**
 * SSH into the server at SERVER_DOMAIN as root using via local SSH keys
 * mkdir /root/config
 * rsync local configurationFiles to that directory
 * cd /root/config
 * chmod +x *.sh
 * exectue config.sh
 */

