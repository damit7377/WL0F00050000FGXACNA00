@echo off
setlocal

cd /d "%~dp0"

set "SREC_CAT=%CD%\srec_cat.exe"
set "BOOT_BIN=%CD%\..\STM32CubeIDE\Boot\Debug\H7R_70D5_Boot.bin"
set "APPLI_HEX=%CD%\..\STM32CubeIDE\Appli\Debug\H7R_70D5_Appli.hex"
set "APPLI_BIN=%CD%\APPLI.BIN"
set "RESORCE_BIN=%CD%\RESORCE.BIN"
set "OUTPUT_HEX=%CD%\H7R_70D5_All.hex"

set "BOOT_BASE=0x08000000"
set "APPLI_BASE=0x70000000"
set "APPLI_END=0x70100000"
set "RESORCE_BASE=0x70100000"
set "RESORCE_END=0x72000000"

echo ============================================================
echo Firmware image generation
echo ============================================================
echo SRecord tool : "%SREC_CAT%"
echo Boot input   : "%BOOT_BIN%"
echo Appli input  : "%APPLI_HEX%"
echo.

if not exist "%SREC_CAT%" (
  echo ERROR: srec_cat.exe not found: "%SREC_CAT%"
  exit /b 1
)

if not exist "%BOOT_BIN%" (
  echo ERROR: Boot binary not found: "%BOOT_BIN%"
  echo Please build the Boot project first.
  exit /b 1
)

if not exist "%APPLI_HEX%" (
  echo ERROR: Appli hex not found: "%APPLI_HEX%"
  echo Please build the Appli project first.
  exit /b 1
)

if exist "%APPLI_BIN%" del "%APPLI_BIN%"
if exist "%RESORCE_BIN%" del "%RESORCE_BIN%"
if exist "%OUTPUT_HEX%" del "%OUTPUT_HEX%"

echo [1/3] Generating application binary...
"%SREC_CAT%" "%APPLI_HEX%" -Intel ^
  -crop %APPLI_BASE% %APPLI_END% ^
  -offset -%APPLI_BASE% ^
  -o "%APPLI_BIN%" -binary
if errorlevel 1 (
  echo ERROR: Failed to generate "%APPLI_BIN%"
  exit /b 1
)

echo [2/3] Generating resource binary...
"%SREC_CAT%" "%APPLI_HEX%" -Intel ^
  -crop %RESORCE_BASE% %RESORCE_END% ^
  -offset -%RESORCE_BASE% ^
  -o "%RESORCE_BIN%" -binary
if errorlevel 1 (
  echo ERROR: Failed to generate "%RESORCE_BIN%"
  exit /b 1
)

echo [3/3] Combining boot, application, and resources...
"%SREC_CAT%" "%BOOT_BIN%" -binary -offset %BOOT_BASE% ^
  "%APPLI_BIN%" -binary -offset %APPLI_BASE% ^
  "%RESORCE_BIN%" -binary -offset %RESORCE_BASE% ^
  -o "%OUTPUT_HEX%" -Intel
if errorlevel 1 (
  echo ERROR: Failed to generate "%OUTPUT_HEX%"
  exit /b 1
)

echo.
echo Generated files:
for %%F in ("%APPLI_BIN%" "%RESORCE_BIN%" "%OUTPUT_HEX%") do echo   %%~fF ^(%%~zF bytes^)
echo Firmware image generation completed successfully.

endlocal
