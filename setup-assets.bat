@echo off
setlocal
REM Run this from the folder that contains NetHackW.exe, tiles.bmp, and sounds\
REM It writes assets-snippet.nh with absolute paths for you to merge into defaults.nh

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"
set "TILE=%ROOT%\tiles.bmp"
set "SND=%ROOT%\sounds"

if not exist "%TILE%" (
  echo ERROR: tiles.bmp not found in %ROOT%
  echo Copy tiles.bmp next to NetHackW.exe first.
  pause
  exit /b 1
)
if not exist "%SND%\hit.wav" (
  echo ERROR: sounds\hit.wav not found in %ROOT%
  echo Copy the sounds folder next to NetHackW.exe first.
  pause
  exit /b 1
)

set "OUT=%ROOT%\assets-snippet.nh"
(
echo # Paste these lines into your defaults.nh / .nethackrc
echo # configdir is shown in-game under Options [O]
echo OPTIONS=tile_file:%TILE%,tile_width:32,tile_height:32
echo SOUNDDIR=%SND%
echo SOUND=MESG "This door is locked." "lock.wav" 100
echo SOUND=MESG "The door resists!" "door_resist.wav" 100
echo SOUND=MESG "The door opens." "door_open.wav" 100
echo SOUND=MESG "You hear a door open." "door_open.wav" 50
echo SOUND=MESG "The door closes." "door_close.wav" 100
echo SOUND=MESG "it crashes open" "door_crash.wav" 100
echo SOUND=MESG "The door crashes open" "door_crash.wav" 100
echo SOUND=MESG "The door splinters!" "door_crash.wav" 100
echo SOUND=MESG "WHAMMM!!!" "wham.wav" 100
echo SOUND=MESG "THUD!" "thud.wav" 100
echo SOUND=MESG "Klunk!" "metal.wav" 100
echo SOUND=MESG "You finish eating" "eat.wav" 100
echo SOUND=MESG "You are beginning to feel hungry." "hungry.wav" 50
echo SOUND=MESG "You are beginning to feel weak." "hungry.wav" 75
echo SOUND=MESG "needs food, badly!" "hungry.wav" 100
echo SOUND=MESG "You die." "death.wav" 100
echo SOUND=MESG "You die " "death.wav" 100
echo SOUND=MESG "hits!" "hit.wav" 40
echo SOUND=MESG "hit!" "hit.wav" 40
echo SOUND=MESG "misses" "miss.wav" 25
echo SOUND=MESG "You kill " "kill.wav" 80
echo SOUND=MESG "is killed!" "kill.wav" 80
echo SOUND=MESG "You hear " "ambient.wav" 20
echo SOUND=MESG "Welcome to experience level" "levelup.wav" 100
echo SOUND=MESG "You feel lucky!" "lucky.wav" 80
echo SOUND=MESG "You feel deathly cold." "cold.wav" 80
echo SOUND=MESG "picks up" "pickup.wav" 30
echo SOUND=MESG "drops" "drop.wav" 30
echo SOUND=MESG "You sit down." "sit.wav" 50
echo SOUND=MESG "zaps" "zap.wav" 60
echo SOUND=MESG "You zap" "zap.wav" 60
echo SOUND=MESG "The spell fails" "fizzle.wav" 70
echo SOUND=MESG "burns" "fire.wav" 50
echo SOUND=MESG "You fall into a pit!" "fall.wav" 100
echo SOUND=MESG "A trap door opens" "trap.wav" 80
echo SOUND=MESG "A trap door in the ceiling opens" "trap.wav" 80
echo SOUND=MESG "Click! You trigger a" "trap.wav" 80
) > "%OUT%"

echo.
echo Wrote %OUT%
echo.
echo NEXT STEPS:
echo 1. In NetHack press O and find "configdir" — open that folder.
echo 2. Edit defaults.nh (or .nethackrc) there.
echo 3. Remove any old SOUNDDIR / SOUND= / tile_file lines that use relative paths.
echo 4. Paste the contents of assets-snippet.nh into that file and save.
echo 5. Restart NetHack.
echo.
pause
