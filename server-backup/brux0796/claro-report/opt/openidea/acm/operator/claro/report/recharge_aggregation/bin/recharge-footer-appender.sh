@echo off

set _WORKING_DIR=%1
set _FILE_NAME=%2
type %_WORKING_DIR%\%_FILE_NAME%.footer >> %_WORKING_DIR%\%_FILE_NAME%.txt