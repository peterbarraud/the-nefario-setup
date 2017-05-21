ECHO off

SET commonfolderpath=..\..\..\common.bat\
SET mariadbpath=..\..\..\mariadb.min\bin\mysql

CALL:getappdata

REM Re-execute the main db.sql
%mariadbpath% --port=%port% --user=root --password= --database=%dbname% < db.reinit.sql

call %commonfolderpath%alldone.bat endprompt

call %commonfolderpath%manageerror.bat handleerror

GOTO:EOF

:getappdata
    call %commonfolderpath%getappdata.bat getValueForKey dbusername ..\app.data
    SET username=%value%

    call %commonfolderpath%getappdata.bat getValueForKey dbusername ..\app.data
    SET username=%value%

    call %commonfolderpath%getappdata.bat getValueForKey dbpwd ..\app.data
    SET pwd=%value%

    call %commonfolderpath%getappdata.bat getValueForKey dbname ..\app.data
    SET dbname=%value%

    GOTO:EOF
