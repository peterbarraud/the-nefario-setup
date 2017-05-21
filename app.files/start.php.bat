ECHO off

call ..\..\common.bat\getappdata.bat getValueForKey phpport app.data
SET phpport=%value%

call ..\..\common.bat\getappdata.bat getValueForKey appname app.data
SET appname=%value%

SET phpdir=..\..\php.min

ECHO Running PHP on PORT %phpport%

%phpdir%\php -S localhost:%phpport% -t ..\..\%appname%\services -c %phpdir%\php.ini

call ..\..\common.bat\manageerror.bat handleerror
