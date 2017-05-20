ECHO off

call common.bat\getappdata.bat getValueForKey phpport
SET phpport=%value%

call common.bat\getappdata.bat getValueForKey appname
SET appname=%value%

call common.bat\getappdata.bat getValueForKey phpdir
SET phpdir=%value%

ECHO Running PHP on PORT %phpport%

%phpdir%\php -S localhost:%phpport% -t %appname%\services -c %phpdir%\php.ini

call common.bat\manageerror.bat handleerror


