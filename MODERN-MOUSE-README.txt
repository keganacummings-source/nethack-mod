NETHACK 5.0 -- MODERN + MOUSE MOD
=================================
What changed (source patch):
  src/cmd.c              right-click now opens a context dropdown for ANY tile;
                         left-click = move / travel / open door / attack / use
                         stairs automatically. Many more menu entries.
  win/win32/mhmap.c      - hold LEFT click and drag: character follows the mouse
                           in real time (re-issues travel/move as you move)
                         - SCROLL WHEEL zooms the map in/out (0.25x .. 6x)
                         - enemy HP bars drawn above visible monsters
                         - floating damage numbers (call mswin_map_float_damage)
                         - double left-click no longer counts as a right click
  sys/windows/nethackrc.template
                         modern default config: dark theme, pixel-style Consolas
                         fonts, scaled tile map, docked inventory, hover text

----------------------------------------------------------------------
1. BUILD IT (Windows, one time)
----------------------------------------------------------------------
Option A - Visual Studio (free "Community" edition)
  1. Install Visual Studio Community; tick the "Desktop development with C++"
     workload.
  2. Unzip this folder somewhere short, e.g.  C:\nh
  3. Start menu -> "x64 Native Tools Command Prompt for VS"
  4. Run:
         cd C:\nh\sys\windows\vs
         msbuild NetHack.sln /t:Build /p:Configuration=Release /p:Platform=x64
     (or open NetHack.sln in Visual Studio, pick Release + x64,
      Build > Build Solution)
  5. The game ends up in   C:\nh\binary\Release\x64\   -> run NetHackW.exe

Option B - no compiler at all (GitHub)
  1. Make a free GitHub account, create a new repository, upload this folder
     (including the hidden .github folder).
  2. Repo -> Actions -> "Build NetHack Windows" -> Run workflow.
  3. When it finishes, download the artifact "NetHack-modern-mouse-win-x64".

If the build prints errors, send me the text of the first "error" line.

----------------------------------------------------------------------
2. FIRST RUN / CONFIG
----------------------------------------------------------------------
NetHack reads  %USERPROFILE%\NetHack\.nethackrc  . If you already have one from
a previous install it overrides the new defaults. To get the modern look:
  - rename/delete your old .nethackrc, then copy
    sys\windows\nethackrc.template  to  %USERPROFILE%\NetHack\.nethackrc
  - the file MUST contain  OPTIONS=mouse_support:1  or clicks do nothing.
Edit that file in Notepad to change fonts, colours, tiles, etc.

Pixel fonts: the default uses Consolas for a crisp terminal look. For a more
"pixel" feel, install a font such as "Press Start 2P" or "Pixel Operator" and
set font_message / font_menu / font_status to that name in .nethackrc.

----------------------------------------------------------------------
3. HOW TO PLAY WITH THE MOUSE
----------------------------------------------------------------------
LEFT CLICK on the map (does the sensible thing automatically)
  far tile ............. travel there (auto-walks, stops if something appears)
  next to you .......... step / attack the monster / open a closed door
                         (kick if locked) / search a wall
  on yourself .......... stairs up/down, drink from fountain, sit on throne,
                         pick up or loot items here, otherwise rest 1 turn

HOLD LEFT CLICK + MOVE the mouse over the map
  your character continuously follows the cursor (real-time pathing / steps)

SCROLL WHEEL over the map
  zoom in for close-up immersive tiles, zoom out to see more of the level

RIGHT CLICK on a tile -> small dropdown of what you can do there
  on yourself .......... pick up / loot / eat what's here, stairs, rest,
                         search, look here, pray, engrave, cast spell,
                         apply, eat, quaff, read, zap, wield, wear, take off,
                         put on / remove accessory, throw, inventory,
                         dungeon overview, options
  next to you .......... open/close/kick door, unlock, attack, talk to pet or
                         peaceful, swap with pet, ride, push boulder, disarm
                         trap, kick, throw, fire quiver, move there,
                         look at it
  further away ......... travel here, look at it, throw / fire quiver that
                         way (when lined up in a straight/diagonal line)

ON-SCREEN FEEDBACK
  Enemy HP bars ........ thin bars above visible monsters (green/yellow/red)
  Damage numbers ....... floating red numbers when damage is reported
                         (wired via mswin_map_float_damage from combat code)

Item menus: after choosing e.g. "Quaff a potion" a list of your items pops up;
click the item, then OK (or press Enter). Same for Wield, Wear, Throw, etc.

Still needs the keyboard (NetHack asks for text or a direction):
  Esc to cancel a prompt, typing names / engravings / wishes, and the
  "In what direction?" prompt (press a direction key, or Esc).
  Handy keys: ? help, i inventory, s search, 20s rest 20, < > stairs,
  _ travel, ; farlook, ^p message history, S save.

Starting out: pick a role in the dialog (Valkyrie is the friendliest).
Your pet (little d / f) follows you. Goal: dive down the Dungeons of Doom,
fetch the Amulet of Yendor. Pray (right-click yourself -> Pray) if HP is
very low -- works once every ~1000 turns. Don't eat unidentified corpses
that look old.
