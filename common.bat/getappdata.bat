@echo off
call :%*
GOTO:EXIT

REM application data is stored in the app.data file
:getValueForKey
	SET appdatapath=%2
	SET currentworkingdir=%~dp0
	REM If we haven't already, we need to get the data from the app.data file (but only once for a bat session)
	if "%appinfo%"=="" (
		for /f "delims=" %%a in ('
			"<nul cmd /q /c "for /f "usebackq delims=" %%z in (%appdatapath%^) do (set /p ".=%%z "^)""
		') do set "appinfo=%%a"
	)
	SET value=%1
	CALL SET value=%%appinfo:*%value%:=%%
	SET value=%value:;=&rem.%
	GOTO:EOF

:EXIT
exit /b


