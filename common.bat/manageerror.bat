@echo off
call :%~1
GOTO:EXIT

REM The error will display anyway. We just want to pause execution for someone to see the error
REM But we're putting this into a common file, just in case at a later point we want to expand the error handle functionality
:handleerror
	IF %ERRORLEVEL% NEQ 0 pause
GOTO:EOF

:EXIT
exit /b