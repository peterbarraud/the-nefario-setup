ECHO off

call ..\..\..\common.bat\getappdata.bat getValueForKey dbusername ..\app.data
SET username=%value%

call ..\..\..\common.bat\getappdata.bat getValueForKey dbusername ..\app.data
SET username=%value%

call ..\..\..\common.bat\getappdata.bat getValueForKey dbpwd ..\app.data
SET pwd=%value%

call ..\..\..\common.bat\getappdata.bat getValueForKey dbname ..\app.data
SET dbname=%value%

ECHO drop database if exists %dbname%; > db-reinit.sql
ECHO create database if not exists %dbname%; >> db-reinit.sql

..\..\..\mariadb.min\bin\mysql --user=root --password= --database=%dbname% < db-reinit.sql

del db-reinit.sql

REM Re-execute the main db.sql
..\..\..\mariadb.min\bin\mysql --port=%port% --user=root --password= --database=%dbname% < db.sql


call ..\..\..\common.bat\alldone.bat endprompt

call ..\..\..\common.bat\manageerror.bat handleerror