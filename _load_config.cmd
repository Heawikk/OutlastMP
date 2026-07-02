@echo off
REM Reads config.ini and exports variables. Must be called via CALL.
for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%~dp0config.ini") do (
    set "%%A=%%B"
)
if "%GAME_DIR%"=="" exit /b 0
if "%GAME_VERSION%"=="" set "GAME_VERSION=Win64"
set "GAME=%GAME_DIR%\Binaries\%GAME_VERSION%\OLGame.exe"
set "DST_DIR=%GAME_DIR%\OLGame\CookedPCConsole\OLMP"
set "DST=%DST_DIR%\Multiplayer.u"
