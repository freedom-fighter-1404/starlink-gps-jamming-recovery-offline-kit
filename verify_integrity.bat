@echo off
setlocal

cd /d "%~dp0"

echo ============================================================
echo Starlink Offline Kit - Integrity Verification (Windows)
echo ============================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0verify_integrity.ps1"
if errorlevel 1 (
  echo.
  echo VERIFICATION FAILED.
  echo Do NOT run the kit if you did not expect changes.
  echo.
  pause
  exit /b 1
)

echo.
echo VERIFICATION OK.
pause
exit /b 0

