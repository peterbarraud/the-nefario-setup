ECHO off

call ..\..\common.bat\getappdata.bat getValueForKey dbusername app.data
SET username=%value%

call ..\..\common.bat\getappdata.bat getValueForKey dbpwd app.data
SET pwd=%value%

call ..\..\common.bat\getappdata.bat getValueForKey dbname app.data
SET dbname=%value%


%mariadbdir%\bin\mysql --user=%username% --password=%pwd% --database=%dbname%

call ..\..\common.bat\manageerror.bat handleerror