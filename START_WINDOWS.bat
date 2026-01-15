@echo off
setlocal enabledelayedexpansion

REM Starlink GPS Anti-Jamming (Offline) - Windows launcher
REM Uses bundled grpcurl.exe (no internet needed)

set "ROOT=%~dp0"
set "GRPCURL=%ROOT%bin\grpcurl\windows-x86_64\grpcurl.exe"
set "DISH_IP=192.168.100.1"
set "GRPC_PORT=9200"
set "TARGET=%DISH_IP%:%GRPC_PORT%"
set "METHOD=SpaceX.API.Device.Device/Handle"

REM grpcurl safety timeouts (seconds). You may override by setting env vars.
if "%GRPC_CONNECT_TIMEOUT%"=="" set "GRPC_CONNECT_TIMEOUT=5"
if "%GRPC_MAX_TIME%"=="" set "GRPC_MAX_TIME=15"

if not exist "%GRPCURL%" (
  echo ERROR: grpcurl.exe not found at:
  echo   %GRPCURL%
  echo
  echo This offline kit expects grpcurl to be bundled.
  pause
  exit /b 1
)

:menu
cls
echo ============================================================
echo Starlink GPS Anti-Jamming (Offline) - Windows
echo Dish: %TARGET%
echo ============================================================
echo 1^) Disable GPS (dish_inhibit_gps=true)
echo 2^) Enable  GPS (dish_inhibit_gps=false)
echo 3^) Status (get_status)
echo 4^) Probe (list/describe + GPS field scan)
echo 5^) Daemon disable (re-send every 5 min)
echo 6^) Exit
echo.
set /p "choice=Choose (1-6): "

if "%choice%"=="1" goto disable
if "%choice%"=="2" goto enable
if "%choice%"=="3" goto status
if "%choice%"=="4" goto probe
if "%choice%"=="5" goto daemon
if "%choice%"=="6" goto end

echo Invalid choice.
pause
goto menu

:disable
echo Sending: dish_inhibit_gps (disable GPS)
"%GRPCURL%" -plaintext -connect-timeout %GRPC_CONNECT_TIMEOUT% -max-time %GRPC_MAX_TIME% -d "{\"dish_inhibit_gps\":{\"inhibit_gps\":true}}" %TARGET% %METHOD%
if errorlevel 1 (
  echo.
  echo FAILED.
  echo Common causes:
  echo   - Not connected to Starlink Wi-Fi / local LAN
  echo   - Older firmware (no dish_inhibit_gps)
  echo   - Reflection unavailable (try Probe)
  echo.
  echo Next steps:
  echo   - Run Probe from the menu
  echo   - If the Starlink app has the toggle, enable: "Use Starlink positioning exclusively"
  echo   - See docs\OLDER_FIRMWARE.md
)
echo.
pause
goto menu

:enable
echo Sending: dish_inhibit_gps (enable GPS)
"%GRPCURL%" -plaintext -connect-timeout %GRPC_CONNECT_TIMEOUT% -max-time %GRPC_MAX_TIME% -d "{\"dish_inhibit_gps\":{\"inhibit_gps\":false}}" %TARGET% %METHOD%
if errorlevel 1 (
  echo.
  echo FAILED. Run Probe from the menu.
)
echo.
pause
goto menu

:status
echo Requesting: get_status
echo (Look for gps/inhibit fields in output)
echo.
"%GRPCURL%" -plaintext -connect-timeout %GRPC_CONNECT_TIMEOUT% -max-time %GRPC_MAX_TIME% -d "{\"get_status\":{}}" %TARGET% %METHOD%
echo.
pause
goto menu

:probe
echo [1/3] List services:
"%GRPCURL%" -plaintext -connect-timeout %GRPC_CONNECT_TIMEOUT% -max-time %GRPC_MAX_TIME% %TARGET% list
if errorlevel 1 (
  echo.
  echo Probe failed: could not connect to %TARGET%.
  echo Make sure you are connected to Starlink Wi-Fi / local LAN, then retry.
  echo.
  pause
  goto menu
)
echo.
echo [2/3] Describe request message and filter GPS-ish lines:
REM findstr is a simple filter; output still depends on reflection support
"%GRPCURL%" -plaintext -connect-timeout %GRPC_CONNECT_TIMEOUT% -max-time %GRPC_MAX_TIME% %TARGET% describe SpaceX.API.Device.Request | findstr /I "gps inhibit position location gnss constellation"
echo.
echo [3/3] Quick check for dish_inhibit_gps:
"%GRPCURL%" -plaintext -connect-timeout %GRPC_CONNECT_TIMEOUT% -max-time %GRPC_MAX_TIME% %TARGET% describe SpaceX.API.Device.Request | findstr /I "dish_inhibit_gps"
echo.
pause
goto menu

:daemon
echo Daemon mode: re-sending disable command every 300 seconds
echo Press Ctrl+C to stop
echo.

:daemon_loop
echo [%time%] disable -> %TARGET%
"%GRPCURL%" -plaintext -connect-timeout %GRPC_CONNECT_TIMEOUT% -max-time %GRPC_MAX_TIME% -d "{\"dish_inhibit_gps\":{\"inhibit_gps\":true}}" %TARGET% %METHOD%
echo.
timeout /t 300 /nobreak >nul
goto daemon_loop

:end
endlocal
exit /b 0
