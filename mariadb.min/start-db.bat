ECHO off

ECHO MariaDB running > mdb.running

bin\mysqld

..\common.bat\manageerror.bat handleerror

