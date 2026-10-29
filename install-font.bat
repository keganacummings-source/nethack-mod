@echo off
REM Downloads and installs VT323 (the pixel font used by the nethackrc theme).
REM Requires Windows 10+ and internet access.
REM Run as Administrator for "install for all users" (recommended).
setlocal

set "FONT_URL=https://fonts.gstatic.com/s/vt323/v17/pxiKyp0ihIEF2isQFJXAdkNL.woff2"
set "FONT_URL_TTF=https://github.com/googlefonts/VT323/raw/main/fonts/VT323-Regular.ttf"
set "FONT_FILE=%TEMP%\VT323-Regular.ttf"
set "FONT_DEST=%WINDIR%\Fonts\VT323-Regular.ttf"

echo Downloading VT323-Regular.ttf...
curl -L "%FONT_URL_TTF%" -o "%FONT_FILE%"
if not exist "%FONT_FILE%" (
    echo ERROR: Download failed. Install manually from https://fonts.google.com/specimen/VT323
    pause
    exit /b 1
)

echo Installing font...
copy /Y "%FONT_FILE%" "%FONT_DEST%"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "VT323 Regular (TrueType)" /t REG_SZ /d "VT323-Regular.ttf" /f

echo.
echo VT323 installed. Restart NetHack to apply.
pause
