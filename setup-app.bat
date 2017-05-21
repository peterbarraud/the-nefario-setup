ECHO off

REM This is a NON-DESTRUCTIVE script. It copies or makes a whole pile of stuff. While doing so it will NEVER overwrite stuff
REM If the script finds that any destination that it is writing to already exists, it will error out as soon as it possibly can


REM Arguments:
REM phpport
REM dbname
REM dbusername
REM dbpwd
REM appname

SET goodsofar=1

set argCount=0
for %%x in (%*) do Set /A argCount+=1

REM There must be exactly 5 args to this scrpt
IF %goodsofar% EQU 1 (
	IF %argCount% LSS 5 (
		REM Show help
		CALL:gethelp
		SET goodsofar=0
	)
)
REM The port number for PHP must be between 9001 and 9999. Both included
IF %goodsofar% EQU 1 (
	IF %1 LEQ 9000 (
		ECHO The first argument, PHP Port, much be a nunber between 9000 and 10000. Both excluded. You set it less than 9001: %1
		SET goodsofar=0
	) ELSE (
		IF %1 GEQ 10000 (
			ECHO The first argument, PHP Port, much be a nunber between 9000 and 10000. Both excluded. You set it greater than 9999: %1
			SET goodsofar=0
		)
	)
)

IF %goodsofar% EQU 1 (
	SET phpport=%1
	SET dbname=%2
	SET dbusername=%3
	SET dbpwd=%4
	SET appname=%5
)

IF %goodsofar% EQU 1 (
	IF EXIST %appname%\app.files (
		ECHO WARNING: The app.files folder is already exists for this project. You have most probably run this script on this project before
		ECHO If you want to run this script again, you will need to delete all the startup folders
		ECHO Be super careful before doing that. Are you deleting files on an WIP project
		SET goodsofar=0
	)
)
IF %goodsofar% EQU 1 (
	IF EXIST %appname%\app.files\db.init (
		ECHO The data init folder %appname%\app.files\db.init already exists. This script DOES NOT overwrite any files or folders
		SET goodsofar=0
	)
)
IF %goodsofar% EQU 1 (
	IF EXIST %appname%\services (
		ECHO The services folder %appname%\services already exists. This script DOES NOT overwrite any files or folders
		SET goodsofar=0
	)
)
REM Check if MariaDB is started. If not try to start it up
IF %goodsofar% EQU 1 (
	echo 1
	IF NOT EXIST mariadb.min\mdb.running (
		setlocal EnableDelayedExpansion
		REM Start MariaDB
		cd mariadb.min
		REM In the MIN mode. So you're not going to see a Command window running. So, probably, the only way to stop this is by using the stop-db.bat
		start /MIN start-db.bat
		cd ..
		REM We're going to wait to make sure it got started
		SET goodsofar=0
		SET counter=1
		:checkfordbrun
		REM But we're not going to check indefinitely
		IF !counter! LSS 6 (
			IF EXIST mariadb.min\mdb.running (
				SET goodsofar=1
			) ELSE (
				REM The SLEEP command does not seem to work so I'm using the following hack - Courtsey: http://stackoverflow.com/questions/4317020/windows-batch-sleep
				ping -n 2 127.0.0.1 >nul
				SET /A counter=counter+1
				GOTO:checkfordbrun
			)
		)
	)
)

IF %goodsofar% EQU 1 (
	CALL:setupdb
	CALL:createngapp
	CALL:createappdatafile
	CALL:copyappstartupfiles
	CALL:copydatainitfiles
	CALL:copyservicesfolder
	CALL:copyngappfiles
	CALL:createrestservice
	CALL:createappusercomponent

	REM All done. Let's run stuff
	REM First, PHP services
	cd %appname%\app.files
	start "%appname% PHP Servies" /MIN start.php.bat
	REM Then, Visual Studio Code
	cd ..\

	code .

	REM And finally, let's just cd back to the prompt that we started at
	cd ..\

	ECHO We are all done here! But you're not
	ECHO In Visual Studio Code, open app.module.ts and register the Rest Service in your app.
	ECHO For some reason, ng-cli does not do this for Services. In their defence, they DO warn you went you run the ng g service command
	ECHO IMPORTANT
	ECHO Both MariaDB and PHP have been opened in the MIN mode. This means that you will not see command Windows open for either of these
	ECHO If you want to shut down MariaDB, you can go to the maria.min folder and run stop-db.bat
	ECHO If you want to shut down the PHP service, you can find the windows in the Taskbar at the bottom
	ECHO It just doesn't show up when you Alt+Tab. At least not until you go to it once from the Taskbar


)

GOTO:EOF

REM Create the NG App
:createngapp
	ECHO Running createngapp
	IF NOT EXIST %appname% (
		ng new %appname%
	)
	ECHO ++++++++++++++++++
	GOTO:EOF

REM Create the app.data file
:createappdatafile
	ECHO Running createappdatafile
	md %appname%\app.files\
	ECHO phpport:%phpport%; > %appname%\app.files\app.data
	ECHO dbname:%dbname%; >> %appname%\app.files\app.data
	ECHO dbusername:%dbusername%; >> %appname%\app.files\app.data
	ECHO dbpwd:%dbpwd%; >> %appname%\app.files\app.data
	ECHO appname:%appname%; >> %appname%\app.files\app.data

	ECHO ++++++++++++++++++++++++
	GOTO:EOF
	
REM Copy the app startup files
:copyappstartupfiles
	ECHO Running copyappstartupfiles
	copy app.files\login.user.bat %appname%\app.files\
	copy app.files\start.php.bat %appname%\app.files\

	ECHO ++++++++++++++++++++++++++
	GOTO:EOF

REM Copy the data init files
:copydatainitfiles
	ECHO Running copydatainitfiles
	md %appname%\app.files\db.reinit
	copy app.files\db.init\*reinit* %appname%\app.files\db.reinit

	ECHO +++++++++++++++++++++++++
	GOTO:EOF

REM Copy the services folder
:copyservicesfolder
	ECHO Running copyservicesfolder
	md %appname%\services
	xcopy /SYD app.files\services %appname%\services
	lib\fart.exe %appname%\services\objectlayer\datalayer.php databaseusername %dbusername%
	lib\fart.exe %appname%\services\objectlayer\datalayer.php databasepassword %dbpwd%
	lib\fart.exe %appname%\services\objectlayer\datalayer.php databasename %dbname%
	
	ECHO +++++++++++++++++++++++++
	GOTO:EOF

REM Copy the ng-app files. But make sure you first run the ng-cli commands to create these files in your app and only then copy run this entire batch file
REM That means we should fail the batch if the files don't already exist
:copyngappfiles
	REM At this point, unfortunately, we are not able to do a check if these files exist. Simply because these files need to exist before we run this script
	REM You will need to create these files using the ng-cli to get things started. In fact, that is a basic pre-req of this script.
	ECHO Running copyngappfiles
	copy app.files\app.component.html %appname%\src\app\app.component.html
	
	ECHO +++++++++++++++++++++
	GOTO:EOF

REM Create the ng Rest Service in the app folder
:createrestservice
	ECHO Running createrestservice
	IF NOT EXIST %appname%\src\app\rest.service.ts (
		ECHO got to create service
		cd %appname%
		ng g service rest.service
		cd ..
		copy app.files\rest.service.ts %appname%\src\app
		lib\fart.exe %appname%\src\app\rest.service.ts localhostrestserverlocation http://localhost:%phpport%/rest.api.php/
	)
	
	ECHO ++++++++++++++++++++++++
	GOTO:EOF
	
REM Create the AppUser component	
:createappusercomponent
	ECHO Running createappusercomponent
	IF NOT EXIST %appname%\src\app\app-user (
		ECHO got to create component
		cd %appname%
		ng g component AppUser
		cd ..
		copy app.files\app-user\* %appname%\src\app\app-user
	)
	
	ECHO ++++++++++++++++++
	GOTO:EOF


REM Set up the db
:setupdb
	ECHO Running setupdb
	
	REM Don't do anything if this user already exists
	ECHO create user if not exists '%dbusername%'@'localhost' identified by '%dbpwd%'; > db-init_temp.sql

	REM Next we create the database. But only if it doesn't already exist
	ECHO create database if not exists %dbname%; >> db-init_temp.sql

	REM We grant all permission to this user on this database
	ECHO grant all on %dbname%.* to '%dbusername%'@'localhost'; >> db-init_temp.sql
	
	REM Execute the db init sql file
	mariadb.min\bin\mysql --user=root --password= < db-init_temp.sql

	REM Let's delete db-init_temp.sql
	del db-init_temp.sql

	REM Then execute the main db.sql
	mariadb.min\bin\mysql --user=root --password= --database=%dbname% < app.files\db.init\db.sql

	GOTO:EOF


:gethelp
	ECHO The arguments requried for this scripr are (and in this order):
	ECHO PHPPort DatabaseName DatabaseUser DatabaseUserPassword AppName
	ECHO PHP Port number on which you will run the services for this application - Must be between 9001 and 9999 (Both included)
	ECHO Database name that will be created for this application
	ECHO Database user name that will be given full privileges on the above database
	ECHO Database user password
	ECHO App name for the web app that you've created. You should have created this app before running this script.
	REM We're putting the pause statement in there in case, someone double-clicks the bat to run it
	pause
	GOTO:EOF