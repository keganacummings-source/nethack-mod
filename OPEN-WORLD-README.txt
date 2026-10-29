OPEN WORLD VERSION
==================
* include/global.h : #define OPENWORLD makes the map 200x60 (was 80x21).
  Comment it out for the classic size. Old save files will not load.
* dat/wildfill.lua : new filler level - lit wilderness with lakes, forests,
  rock ridges, ruined huts (chest + door), altar shrines, fountains.
  Stairs are placed on opposite thirds of the map; the walkable area is
  always one connected region.
* dat/dungeon.lua  : Dungeons of Doom uses lvlfill = "wildfill". Special
  levels (Oracle, Bigroom, Medusa, Castle...) are unchanged.
* src/sp_lev.c     : larger Lua step/memory budget for level scripts.
To go back to rooms and corridors: remove the lvlfill line in dat/dungeon.lua
and comment out OPENWORLD.
Known: no vaults on ordinary levels (so no Fort Ludios portal), Gehennom
mazes are much bigger, Windows GUI build not tested here.
