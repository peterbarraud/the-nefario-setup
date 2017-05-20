@echo off
call :%~1
GOTO:EXIT

REM The error will display anyway. We just want to pause execution for someone to see the error
REM But we're putting this into a common file, just in case at a later point we want to expand the error handle functionality
:endprompt
	echo All DONE!!
	echo Press Enter to close this prompt
	pause >nul
GOTO:EOF

:EXIT
exit /b





