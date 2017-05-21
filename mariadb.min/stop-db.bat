ECHO off

IF EXIST mdb.running (
	del mdb.running
	bin\mysqladmin -u root shutdown
) ELSE (
	ECHO The database server does not seem to be running
	ECHO If you think it is running in the backgroud, try this
	ECHO Delete the mdb.running file that is there in the maria.min folder and then run this same script again
)



call ..\common.bat\manageerror.bat handleerror

REM The following line should show the endprompt if no error occurred but EQ seems to fail
REM IF %ERRORLEVEL% EQ 0 call ..\common.bat\alldone.bat endprompt 