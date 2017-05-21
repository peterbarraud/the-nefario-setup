ECHO off

SET commonfolderpath=..\..\common.bat\
SET mariadbpath=..\..\mariadb.min\bin\mysql
SET appdatapath=app.data
SET objectlayerfolderpath=..\services\objectlayer\

CALL:getappdata

CALL:gettablelist

call %commonfolderpath%alldone.bat endprompt

call %commonfolderpath%manageerror.bat handleerror

GOTO:EOF

:getappdata
    call %commonfolderpath%getappdata.bat getValueForKey dbusername %appdatapath%
    SET username=%value%

    call %commonfolderpath%getappdata.bat getValueForKey dbusername %appdatapath%
    SET username=%value%

    call %commonfolderpath%getappdata.bat getValueForKey dbpwd %appdatapath%
    SET pwd=%value%

    call %commonfolderpath%getappdata.bat getValueForKey dbname %appdatapath%
    SET dbname=%value%

    GOTO:EOF

:gettablelist
    %mariadbpath% --user=%username% --password=%pwd% --database=%dbname% -e"show tables" > tables.tmp
    for /F "tokens=*" %%A in (tables.tmp) do CALL:createservice %%A
    del tables.tmp
    GOTO:EOF

:createservice
    SET tablename=%1
    SET servicefilename=%objectlayerfolderpath%%tablename%.php

    IF NOT "%tablename%"=="Tables_in_%dbname%" (
        REM This is a non-destructive script so we will ONLY a create service file if it doesn't already exist. NO overwrite
        IF NOT EXIST %servicefilename% (
            ECHO ^<?php > %servicefilename%
            ECHO require_once^('objectbase.php'^); >> %servicefilename%
            ECHO class %tablename% extends objectbase {} >> %servicefilename%
            ECHO ?^> >> %servicefilename%
        )
    )
    GOTO:EOF



