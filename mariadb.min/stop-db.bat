ECHO off

bin\mysqladmin -u root shutdown

call ..\common.bat\manageerror.bat handleerror

REM The following line should show the endprompt if no error occurred but EQ seems to fail
REM IF %ERRORLEVEL% EQ 0 call ..\common.bat\alldone.bat endprompt 