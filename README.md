# MongoDB Backup and Restore Automation Script

A Windows batch script that automates MongoDB database backup and restore operations with configurable source and target databases. Perfect for database migrations, backups, and synchronization tasks.

## 🚀 Features

- **Automated Backup & Restore**: One-click MongoDB database backup and restore
- **Flexible Configuration**: JSON-based configuration for easy customization
- **Authentication Support**: Works with both authenticated and non-authenticated MongoDB instances
- **Local & Remote Support**: Backup from/to localhost or remote MongoDB servers
- **Comprehensive Logging**: Detailed logs with timestamps for troubleshooting
- **Error Handling**: Robust error checking and validation
- **Cleanup**: Automatic cleanup of temporary backup files after successful restore

## 📋 Prerequisites

Before using this script, ensure you have the following installed:

### 1. MongoDB Server
- **Download**: [MongoDB Community Server](https://www.mongodb.com/try/download/community)
- **Installation**: Follow the official MongoDB installation guide for Windows
- **Verification**: Ensure MongoDB service is running

### 2. MongoDB Command Line Database Tools
- **Download**: [MongoDB Database Tools](https://www.mongodb.com/try/download/database-tools)
- **Installation**: 
- Download the ZIP file for Windows
- Extract to a directory (e.g., `C:\Program Files\MongoDB\Tools\100\bin`)
- Note the installation path for configuration

### 3. Administrative Privileges
- The script must be run as Administrator
- Right-click Command Prompt and select "Run as administrator"

## 📁 Project Structure

```
mongodb-backup-script/
├── mongodb_backup_restore.bat    # Main batch script
├── backup-config.json           # Configuration file
├── README.md                    # This file
└── logs                        # Generated log files (created automatically)
```

## ⚙️ Installation & Setup

### Step 1: Clone or Download
```bash
git clone https://github.com/MohammadHMazarei/mongodb-backup-restore-automation.git
cd mongodb-backup-restore-automation
```

Or download the ZIP file and extract it to your desired location.

### Step 2: Configure the Script

Edit the `backup-config.json` file with your specific settings:

```json
{
"mongoToolsPath": "C:\\Program Files\\MongoDB\\Tools\\100\\bin",
"backupDirectory": "backup-dir",
"source": {
  "host": "source-host",
  "port": "source-port",
  "authenticationDatabase": "admin",
  "username": "source-username",
  "password": "source-password"
},
"target": {
  "host": "target-host",
  "port": "target-port",
  "authenticationDatabase": "admin",
  "username": "target-username",
  "password": "target-password"
},
"backupName": "backup-name"
}
```

### Step 3: Configuration Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `mongoToolsPath` | Full path to MongoDB tools directory | `"C:\\Program Files\\MongoDB\\Tools\\100\\bin"` |
| `backupDirectory` | Directory where backup files will be stored | `"D:\\backups"` or `"backup-dir"` |
| `source.host` | Source MongoDB server hostname/IP | `"localhost"` or `"127.0.0.1"` |
| `source.port` | Source MongoDB server port | `"27017"` |
| `source.authenticationDatabase` | Authentication database (usually "admin") | `"admin"` |
| `source.username` | Username for source database (leave empty for no auth) | `"myuser"` or `""` |
| `source.password` | Password for source database (leave empty for no auth) | `"mypassword"` or `""` |
| `target.*` | Same parameters as source, but for target database | |
| `backupName` | Name for the backup folder | `"backup_20241203"` |

## 🔧 Usage

### Basic Usage

1. **Open Command Prompt as Administrator**
 - Press `Win + X` and select "Command Prompt (Admin)" or "PowerShell (Admin)"
 - Or right-click Command Prompt and select "Run as administrator"

2. **Navigate to Script Directory**
 ```cmd
 cd C:\path\to\mongodb-backup-restore-automation
 ```

3. **Run the Script**
 ```cmd
 mongodb_backup_restore.bat
 ```

4. **Follow the Prompts**
 - Review the loaded configuration
 - Type `Y` to proceed or `N` to cancel

### Example Scenarios

#### Scenario 1: Local to Local Backup
```json
{
"mongoToolsPath": "C:\\Program Files\\MongoDB\\Tools\\100\\bin",
"backupDirectory": "C:\\temp\\backups",
"source": {
  "host": "localhost",
  "port": "27017",
  "authenticationDatabase": "admin",
  "username": "",
  "password": ""
},
"target": {
  "host": "localhost",
  "port": "27018",
  "authenticationDatabase": "admin",
  "username": "",
  "password": ""
},
"backupName": "local_migration"
}
```

#### Scenario 2: Remote to Local Migration
```json
{
"mongoToolsPath": "C:\\Program Files\\MongoDB\\Tools\\100\\bin",
"backupDirectory": "D:\\database_migrations",
"source": {
  "host": "production-server.company.com",
  "port": "27017",
  "authenticationDatabase": "admin",
  "username": "backup_user",
  "password": "secure_password"
},
"target": {
  "host": "localhost",
  "port": "27017",
  "authenticationDatabase": "admin",
  "username": "",
  "password": ""
},
"backupName": "prod_to_dev_migration"
}
```

## 📊 Script Workflow

1. **Validation Phase**
 - Checks for administrative privileges
 - Validates configuration file exists
 - Verifies MongoDB tools installation
 - Creates backup directory if needed

2. **Backup Phase**
 - Connects to source MongoDB instance
 - Performs `mongodump` operation
 - Saves backup to specified directory
 - Logs all operations

3. **Restore Phase**
 - Connects to target MongoDB instance
 - Performs `mongorestore` operation
 - Restores from backup directory
 - Logs all operations

4. **Cleanup Phase**
 - Removes temporary backup files (on success)
 - Generates completion report

## 📝 Logging

The script generates detailed log files with timestamps:
- **Location**: Same directory as the batch file
- **Format**: `mongodb_backup_restore_YYYYMMDD_HHMMSS.log`
- **Contents**: All operations, errors, and status messages

Example log entry:
```
Starting MongoDB backup process at 12/03/2024 14:30:25
Backing up from localhost without authentication...
MongoDB backup completed successfully
Starting MongoDB restore process at 12/03/2024 14:35:10
Restoring to remote host with authentication...
MongoDB restore completed successfully
```

## ⚠️ Important Notes

### Security Considerations
- **Passwords in Config**: The JSON file contains passwords in plain text. Secure this file appropriately.
- **File Permissions**: Set appropriate file permissions on the configuration file.
- **Network Security**: Ensure secure connections when working with remote databases.

### Best Practices
- **Test First**: Always test with non-production data first
- **Backup Verification**: Verify backup integrity before relying on it
- **Regular Backups**: Schedule regular backups for important databases
- **Monitor Logs**: Review log files for any warnings or errors

### Limitations
- **Windows Only**: This script is designed for Windows environments
- **MongoDB Tools Required**: Requires separate installation of MongoDB Database Tools
- **Single Database**: Backs up entire MongoDB instance, not individual databases

## 🛠️ Troubleshooting

### Common Issues

#### Issue: "mongodump.exe not found"
**Solution**: 
- Verify MongoDB Database Tools are installed
- Check the `mongoToolsPath` in configuration file
- Ensure the path uses double backslashes (`\\`)

#### Issue: "Access Denied" or "Permission Denied"
**Solution**:
- Run Command Prompt as Administrator
- Check file/folder permissions
- Verify MongoDB service is running

#### Issue: "Authentication Failed"
**Solution**:
- Verify username and password in configuration
- Check `authenticationDatabase` setting
- Ensure user has appropriate permissions

#### Issue: "Connection Refused"
**Solution**:
- Verify MongoDB server is running
- Check host and port settings
- Verify network connectivity for remote hosts

### Getting Help

1. **Check Log Files**: Review the generated log files for detailed error messages
2. **Verify Configuration**: Double-check all settings in `backup-config.json`
3. **Test Connectivity**: Use MongoDB Compass or mongo shell to test connections
4. **MongoDB Documentation**: Refer to official MongoDB documentation for `mongodump` and `mongorestore`

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development Setup
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review MongoDB official documentation

## 🔄 Version History

- **v1.0.0** - Initial release
- Basic backup and restore functionality
- JSON configuration support
- Authentication support
- Comprehensive logging

---
