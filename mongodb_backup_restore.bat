@echo off
setlocal enabledelayedexpansion

:: MongoDB Backup and Restore Automation Script for Windows
:: Prerequisites:
:: - MongoDB Server installed
:: - MongoDB Command Line Tools installed

:: Check if running with administrative privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: This script must be run as Administrator. Please right-click CMD and select 'Run as administrator'.
    pause
    exit /b 1
)

:: Store the original directory (where the .bat file is located)
set "SCRIPT_DIR=%~dp0"
set "CONFIG_FILE=%SCRIPT_DIR%backup-config.json"

:: Check if config file exists
if not exist "%CONFIG_FILE%" (
    echo ERROR: Configuration file 'backup-config.json' not found in script directory.
    echo Please create the configuration file with the required parameters.
    echo Expected location: %CONFIG_FILE%
    pause
    exit /b 1
)

:: Display prerequisites warning
echo ==========================================================
echo PREREQUISITES:
echo - MongoDB Server must be installed
echo - MongoDB Command Line Tools must be installed
echo - Configuration file 'backup-config.json' must be present
echo ==========================================================
echo.

echo Reading configuration from: %CONFIG_FILE%
echo.

:: Initialize parsing flags
set "PARSING_SOURCE=false"
set "PARSING_TARGET=false"

:: Read and parse JSON configuration file
for /f "usebackq delims=" %%i in ("%CONFIG_FILE%") do (
    set "line=%%i"
    
    :: Parse mongoToolsPath
    echo !line! | findstr /c:"mongoToolsPath" >nul
    if !errorlevel! equ 0 (
        for /f "tokens=1,* delims=:" %%a in ("!line!") do (
            set "temp=%%b"
            :: Remove quotes, commas, and leading/trailing spaces
            set "temp=!temp:"=!"
            set "temp=!temp:,=!"
            :: Remove leading spaces
            if "!temp:~0,1!"==" " set "temp=!temp:~1!"
            :: Remove trailing spaces
            :trim_mongo_path
            if "!temp:~-1!"==" " (
                set "temp=!temp:~0,-1!"
                goto trim_mongo_path
            )
            :: Convert double backslashes to single backslashes
            set "temp=!temp:\\=\!"
            set "MONGO_TOOLS_PATH=!temp!"
        )
    )
    
    :: Parse backupDirectory
    echo !line! | findstr /c:"backupDirectory" >nul
    if !errorlevel! equ 0 (
        for /f "tokens=1,* delims=:" %%a in ("!line!") do (
            set "temp=%%b"
            :: Remove quotes, commas, and leading/trailing spaces
            set "temp=!temp:"=!"
            set "temp=!temp:,=!"
            :: Remove leading spaces
            if "!temp:~0,1!"==" " set "temp=!temp:~1!"
            :: Remove trailing spaces
            :trim_backup_dir
            if "!temp:~-1!"==" " (
                set "temp=!temp:~0,-1!"
                goto trim_backup_dir
            )
            :: Convert double backslashes to single backslashes
            set "temp=!temp:\\=\!"
            set "BACKUP_DIR=!temp!"
        )
    )
    
    :: Parse backupName
    echo !line! | findstr /c:"backupName" >nul
    if !errorlevel! equ 0 (
        for /f "tokens=1,* delims=:" %%a in ("!line!") do (
            set "temp=%%b"
            set "temp=!temp:"=!"
            set "temp=!temp:,=!"
            :: Remove leading spaces
            if "!temp:~0,1!"==" " set "temp=!temp:~1!"
            :: Remove trailing spaces
            :trim_backup_name
            if "!temp:~-1!"==" " (
                set "temp=!temp:~0,-1!"
                goto trim_backup_name
            )
            set "BACKUP_NAME=!temp!"
        )
    )
    
    :: Track which section we're parsing
    echo !line! | findstr /c:"source" >nul
    if !errorlevel! equ 0 (
        set "PARSING_SOURCE=true"
        set "PARSING_TARGET=false"
    )
    
    echo !line! | findstr /c:"target" >nul
    if !errorlevel! equ 0 (
        set "PARSING_SOURCE=false"
        set "PARSING_TARGET=true"
    )
    
    :: Parse host
    echo !line! | findstr /c:"host" >nul
    if !errorlevel! equ 0 (
        if "!PARSING_SOURCE!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_src_host
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_src_host
                )
                set "SRC_HOST=!temp!"
            )
        )
        if "!PARSING_TARGET!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_tgt_host
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_tgt_host
                )
                set "TGT_HOST=!temp!"
            )
        )
    )
    
    :: Parse port
    echo !line! | findstr /c:"port" >nul
    if !errorlevel! equ 0 (
        if "!PARSING_SOURCE!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_src_port
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_src_port
                )
                set "SRC_PORT=!temp!"
            )
        )
        if "!PARSING_TARGET!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_tgt_port
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_tgt_port
                )
                set "TGT_PORT=!temp!"
            )
        )
    )
    
    :: Parse authenticationDatabase
    echo !line! | findstr /c:"authenticationDatabase" >nul
    if !errorlevel! equ 0 (
        if "!PARSING_SOURCE!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_src_auth
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_src_auth
                )
                set "SRC_AUTH_DB=!temp!"
            )
        )
        if "!PARSING_TARGET!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_tgt_auth
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_tgt_auth
                )
                set "TGT_AUTH_DB=!temp!"
            )
        )
    )
    
    :: Parse username
    echo !line! | findstr /c:"username" >nul
    if !errorlevel! equ 0 (
        if "!PARSING_SOURCE!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_src_user
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_src_user
                )
                set "SRC_USERNAME=!temp!"
            )
        )
        if "!PARSING_TARGET!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_tgt_user
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_tgt_user
                )
                set "TGT_USERNAME=!temp!"
            )
        )
    )
    
    :: Parse password
    echo !line! | findstr /c:"password" >nul
    if !errorlevel! equ 0 (
        if "!PARSING_SOURCE!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_src_pass
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_src_pass
                )
                set "SRC_PASSWORD=!temp!"
            )
        )
        if "!PARSING_TARGET!"=="true" (
            for /f "tokens=1,* delims=:" %%a in ("!line!") do (
                set "temp=%%b"
                set "temp=!temp:"=!"
                set "temp=!temp:,=!"
                if "!temp:~0,1!"==" " set "temp=!temp:~1!"
                :trim_tgt_pass
                if "!temp:~-1!"==" " (
                    set "temp=!temp:~0,-1!"
                    goto trim_tgt_pass
                )
                set "TGT_PASSWORD=!temp!"
            )
        )
    )
)

:: Display loaded configuration
echo ==========================================================
echo LOADED CONFIGURATION:
echo ==========================================================
echo MongoDB Tools Path: %MONGO_TOOLS_PATH%
echo Backup Directory: %BACKUP_DIR%
echo.
echo Source Configuration:
echo   Host: %SRC_HOST%
echo   Port: %SRC_PORT%
echo   Auth DB: %SRC_AUTH_DB%
echo   Username: %SRC_USERNAME%
echo.
echo Target Configuration:
echo   Host: %TGT_HOST%
echo   Port: %TGT_PORT%
echo   Auth DB: %TGT_AUTH_DB%
echo   Username: %TGT_USERNAME%
echo.
echo Backup Name: %BACKUP_NAME%
echo ==========================================================
echo.

:: Ask user if they want to proceed with these settings
set /p PROCEED="Do you want to proceed with these settings? (Y/N): "
if /i not "%PROCEED%"=="Y" (
    echo Operation cancelled by user.
    pause
    exit /b 0
)

:: Validate MongoDB tools path - using exist command properly for paths with spaces
echo Validating MongoDB tools path...
if exist "%MONGO_TOOLS_PATH%\mongodump.exe" (
    echo MongoDB tools found successfully.
) else (
    echo ERROR: mongodump.exe not found in the specified path: %MONGO_TOOLS_PATH%
    echo Please verify that MongoDB Command Line Tools are installed and update the config file.
    pause
    exit /b 1
)

:: Create backup directory if it doesn't exist
if not exist "%BACKUP_DIR%" (
    echo Creating backup directory: %BACKUP_DIR%
    mkdir "%BACKUP_DIR%" 2>nul
    if !errorlevel! neq 0 (
        echo ERROR: Failed to create backup directory: %BACKUP_DIR%
        pause
        exit /b 1
    )
) else (
    echo Backup directory already exists: %BACKUP_DIR%
)

:: Change to backup directory
cd /d "%BACKUP_DIR%"
if !errorlevel! neq 0 (
    echo ERROR: Failed to change to backup directory: %BACKUP_DIR%
    pause
    exit /b 1
)
echo Changed to backup directory: %cd%

:: Set path to MongoDB tools
echo Setting MongoDB tools path...
set "PATH=%MONGO_TOOLS_PATH%;%PATH%"
echo MongoDB tools path set.

:: Check if source is localhost
set "SRC_IS_LOCALHOST=false"
if /i "%SRC_HOST%"=="localhost" set "SRC_IS_LOCALHOST=true"
if /i "%SRC_HOST%"=="127.0.0.1" set "SRC_IS_LOCALHOST=true"
if /i "%SRC_HOST%"=="::1" set "SRC_IS_LOCALHOST=true"

:: Check if target is localhost
set "TGT_IS_LOCALHOST=false"
if /i "%TGT_HOST%"=="localhost" set "TGT_IS_LOCALHOST=true"
if /i "%TGT_HOST%"=="127.0.0.1" set "TGT_IS_LOCALHOST=true"
if /i "%TGT_HOST%"=="::1" set "TGT_IS_LOCALHOST=true"

:: Create log file with timestamp in the same directory as the batch file
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "TIMESTAMP=%dt:~0,8%_%dt:~8,6%"
set "LOG_FILE=%SCRIPT_DIR%mongodb_backup_restore_%TIMESTAMP%.log"
echo. > "%LOG_FILE%"

echo Starting MongoDB backup process at %date% %time% >> "%LOG_FILE%"
echo Starting MongoDB backup process at %date% %time%

:: Perform mongodump with or without authentication
echo Executing mongodump... >> "%LOG_FILE%"
echo Executing mongodump...

if "!SRC_IS_LOCALHOST!"=="true" (
    echo Backing up from localhost without authentication... >> "%LOG_FILE%"
    echo Backing up from localhost without authentication...
    mongodump --host="%SRC_HOST%" --port="%SRC_PORT%" --out="%BACKUP_NAME%" >> "%LOG_FILE%" 2>&1
) else (
    if "%SRC_USERNAME%"=="" (
        echo Backing up from remote host without authentication... >> "%LOG_FILE%"
        echo Backing up from remote host without authentication...
        mongodump --host="%SRC_HOST%" --port="%SRC_PORT%" --out="%BACKUP_NAME%" >> "%LOG_FILE%" 2>&1
    ) else (
        echo Backing up from remote host with authentication... >> "%LOG_FILE%"
        echo Backing up from remote host with authentication...
        mongodump --host="%SRC_HOST%" --port="%SRC_PORT%" --authenticationDatabase="%SRC_AUTH_DB%" -u="%SRC_USERNAME%" -p="%SRC_PASSWORD%" --out="%BACKUP_NAME%" >> "%LOG_FILE%" 2>&1
    )
)

:: Check if mongodump was successful
if %errorlevel% neq 0 (
    echo ERROR: mongodump failed. Check the log file for details: %LOG_FILE% >> "%LOG_FILE%"
    echo ERROR: mongodump failed. Check the log file for details: %LOG_FILE%
    pause
    exit /b 1
)

echo MongoDB backup completed successfully >> "%LOG_FILE%"
echo MongoDB backup completed successfully
echo Starting MongoDB restore process at %date% %time% >> "%LOG_FILE%"
echo Starting MongoDB restore process at %date% %time%

:: Perform mongorestore with or without authentication
echo Executing mongorestore... >> "%LOG_FILE%"
echo Executing mongorestore...

if "!TGT_IS_LOCALHOST!"=="true" (
    echo Restoring to localhost without authentication... >> "%LOG_FILE%"
    echo Restoring to localhost without authentication...
    mongorestore --host="%TGT_HOST%" --port="%TGT_PORT%" "./%BACKUP_NAME%/" >> "%LOG_FILE%" 2>&1
) else (
    if "%TGT_USERNAME%"=="" (
        echo Restoring to remote host without authentication... >> "%LOG_FILE%"
        echo Restoring to remote host without authentication...
        mongorestore --host="%TGT_HOST%" --port="%TGT_PORT%" "./%BACKUP_NAME%/" >> "%LOG_FILE%" 2>&1
    ) else (
        echo Restoring to remote host with authentication... >> "%LOG_FILE%"
        echo Restoring to remote host with authentication...
        mongorestore --host="%TGT_HOST%" --port="%TGT_PORT%" --authenticationDatabase="%TGT_AUTH_DB%" -u="%TGT_USERNAME%" -p="%TGT_PASSWORD%" ".\%BACKUP_NAME%\" >> "%LOG_FILE%" 2>&1
    )
)

:: Check if mongorestore was successful
if %errorlevel% equ 0 (
    echo MongoDB restore completed successfully >> "%LOG_FILE%"
    echo MongoDB restore completed successfully
    
    :: Delete backup files
    echo Cleaning up backup files... >> "%LOG_FILE%"
    echo Cleaning up backup files...
    rmdir /s /q ".\%BACKUP_NAME%"
    echo Backup files deleted. >> "%LOG_FILE%"
    echo Backup files deleted.
) else (
    echo ERROR: mongorestore failed. Backup files will be preserved. >> "%LOG_FILE%"
    echo ERROR: mongorestore failed. Backup files will be preserved.
    echo Please check the log file for details: %LOG_FILE% >> "%LOG_FILE%"
    echo Please check the log file for details: %LOG_FILE%
    pause
    exit /b 1
)

echo MongoDB backup and restore process completed at %date% %time% >> "%LOG_FILE%"
echo MongoDB backup and restore process completed at %date% %time%

:: Return to original directory
cd /d "%SCRIPT_DIR%"
echo Script execution finished.
pause


