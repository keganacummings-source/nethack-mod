-- NetHack wildfill.lua  (Open World fork)
-- NetHack may be freely redistributed.  See license for details.
--
-- The "fill" level for the Dungeons of Doom when OPENWORLD is enabled.
-- Instead of rooms and corridors, every ordinary level is a big, lit
-- wilderness: lakes, forests, rocky ridges, scattered shrines and ruined
-- huts, with the up and down stairs far apart.

des.level_init({ style = "solidfill", fg = " " });
des.level_flags("mazelevel", "noflip");

local W = nhc.COLNO       -- columns 1..W-1 are usable
local H = nhc.ROWNO       -- rows 0..H-1 are usable

---------------------------------------------------------------------------
-- value noise: a coarse random grid, bilinearly interpolated, so the
-- terrain forms big smooth blobs instead of static
---------------------------------------------------------------------------
local function make_field(cell)
   local gw = math.floor(W / cell) + 2
   local gh = math.floor(H / cell) + 2
   local g = {}
   for i = 0, gw do
      g[i] = {}
      for j = 0, gh do
         g[i][j] = math.random(0, 1000) / 1000
      end
   end
   local f = {}
   for x = 0, W - 1 do
      f[x] = {}
      local fx = x / cell
      local ix = math.floor(fx)
      local tx = fx - ix
      tx = tx * tx * (3 - 2 * tx)
      for y = 0, H - 1 do
         local fy = y / cell
         local iy = math.floor(fy)
         local ty = fy - iy
         ty = ty * ty * (3 - 2 * ty)
         local a = g[ix][iy] * (1 - tx) + g[ix + 1][iy] * tx
         local b = g[ix][iy + 1] * (1 - tx) + g[ix + 1][iy + 1] * tx
         f[x][y] = a * (1 - ty) + b * ty
      end
   end
   return f
end

local elev  = make_field(14)   -- low = water, high = mountains
local detail = make_field(5)   -- roughens the edges a little
local moist = make_field(11)   -- high = forest

-- terrain codes: 0 floor, 1 water, 2 rock, 3 tree
local t = {}
for x = 0, W - 1 do
   t[x] = {}
   for y = 0, H - 1 do
      local e = elev[x][y] * 0.8 + detail[x][y] * 0.2
      local m = moist[x][y]
      local c = 0
      if x < 2 or x > W - 3 or y < 1 or y > H - 2 then
         c = 2                                   -- solid border
      elseif e < 0.30 then
         c = 1
      elseif e > 0.72 then
         c = 2
      elseif m > 0.58 and e > 0.38 then
         c = (math.random(1, 100) <= 62) and 3 or 0
      elseif math.random(1, 100) <= 1 then
         c = 3                                   -- lone tree
      end
      t[x][y] = c
   end
end

---------------------------------------------------------------------------
-- connectivity: keep only the biggest walkable region, so the stairs are
-- always reachable (water, trees and rock all block the hero)
---------------------------------------------------------------------------
local comp = {}
for x = 0, W - 1 do comp[x] = {} end

local function flood(sx, sy, id)
   local stack = { { sx, sy } }
   local n = 0
   comp[sx][sy] = id
   while #stack > 0 do
      local p = table.remove(stack)
      n = n + 1
      for dx = -1, 1 do
         for dy = -1, 1 do
            if dx ~= 0 or dy ~= 0 then
               local nx, ny = p[1] + dx, p[2] + dy
               if nx >= 0 and nx < W and ny >= 0 and ny < H
                  and t[nx][ny] == 0 and comp[nx][ny] == nil then
                  comp[nx][ny] = id
                  stack[#stack + 1] = { nx, ny }
               end
            end
         end
      end
   end
   return n
end

local sizes = {}
local nid = 0
for x = 0, W - 1 do
   for y = 0, H - 1 do
      if t[x][y] == 0 and comp[x][y] == nil then
         nid = nid + 1
         sizes[nid] = flood(x, y, nid)
      end
   end
end

local best, bestn = 0, 0
for id = 1, nid do
   if sizes[id] > bestn then best, bestn = id, sizes[id] end
end

-- cut any cell that isn't in the main region off with solid rock; trees
-- would be walkable-looking, so use rock for the cut-off pockets
for x = 0, W - 1 do
   for y = 0, H - 1 do
      if t[x][y] == 0 and comp[x][y] ~= best then
         t[x][y] = 2
      end
   end
end

---------------------------------------------------------------------------
-- points of interest: carve small ruined huts and shrines into open ground
---------------------------------------------------------------------------
local function area_free(x1, y1, x2, y2)
   for x = x1 - 1, x2 + 1 do
      for y = y1 - 1, y2 + 1 do
         if x < 2 or x > W - 3 or y < 1 or y > H - 2 then return false end
         if t[x][y] ~= 0 then return false end
      end
   end
   return true
end

local pois = {}        -- remembered so we can fill them in later
local function try_hut()
   local w, h = math.random(4, 7), math.random(3, 5)
   local x1, y1 = math.random(4, W - w - 5), math.random(3, H - h - 4)
   local x2, y2 = x1 + w - 1, y1 + h - 1
   if not area_free(x1, y1, x2, y2) then return false end
   -- walls
   for x = x1 - 1, x2 + 1 do
      for y = y1 - 1, y2 + 1 do
         if x < x1 or x > x2 or y < y1 or y > y2 then
            des.terrain(x, y, (x == x1 - 1 or x == x2 + 1) and "|" or "-")
            t[x][y] = 4
         end
      end
   end
   for x = x1 - 1, x2 + 1 do
      for y = y1 - 1, y2 + 1 do
         if t[x][y] == 4 then comp[x][y] = nil end
      end
   end
   -- corner glyphs
   des.terrain(x1 - 1, y1 - 1, "-"); des.terrain(x2 + 1, y1 - 1, "-")
   des.terrain(x1 - 1, y2 + 1, "-"); des.terrain(x2 + 1, y2 + 1, "-")
   -- interior floor
   for x = x1, x2 do
      for y = y1, y2 do
         des.terrain(x, y, ".")
         t[x][y] = 5
      end
   end
   -- a door on a random side
   local side = math.random(1, 4)
   local dx, dy
   if side == 1 then dx, dy = math.random(x1, x2), y1 - 1
   elseif side == 2 then dx, dy = math.random(x1, x2), y2 + 1
   elseif side == 3 then dx, dy = x1 - 1, math.random(y1, y2)
   else dx, dy = x2 + 1, math.random(y1, y2) end
   des.terrain(dx, dy, ".")
   des.door({ x = dx, y = dy, state = percent(35) and "locked" or "closed",
              iswall = 0 })
   pois[#pois + 1] = { x1 = x1, y1 = y1, x2 = x2, y2 = y2, kind = "hut" }
   return true
end

local function try_shrine()
   local x1, y1 = math.random(4, W - 9), math.random(3, H - 9)
   if not area_free(x1, y1, x1 + 4, y1 + 4) then return false end
   -- a little ring of stones around an altar
   for _, p in ipairs({ { 0, 0 }, { 4, 0 }, { 0, 4 }, { 4, 4 },
                        { 2, 0 }, { 2, 4 }, { 0, 2 }, { 4, 2 } }) do
      des.terrain(x1 + p[1], y1 + p[2], "T")
      t[x1 + p[1]][y1 + p[2]] = 3
   end
   des.altar({ x = x1 + 2, y = y1 + 2, align = "random", type = "shrine" })
   pois[#pois + 1] = { x1 = x1 + 1, y1 = y1 + 1, x2 = x1 + 3, y2 = y1 + 3,
                       kind = "shrine" }
   return true
end

local function try_fountain()
   local x, y = math.random(4, W - 5), math.random(3, H - 4)
   if not area_free(x, y, x, y) then return false end
   des.feature("fountain", x, y)
   t[x][y] = 6
   return true
end

local huts = 0
for tries = 1, 120 do
   if huts >= math.random(5, 8) then break end
   if try_hut() then huts = huts + 1 end
end
local shrines = 0
for tries = 1, 80 do
   if shrines >= math.random(1, 3) then break end
   if try_shrine() then shrines = shrines + 1 end
end
local fountains = 0
for tries = 1, 80 do
   if fountains >= math.random(3, 6) then break end
   if try_fountain() then fountains = fountains + 1 end
end

---------------------------------------------------------------------------
-- paint the terrain
---------------------------------------------------------------------------
local water = selection.new()
local rock  = selection.new()
local trees = selection.new()
local floor = selection.new()
for x = 0, W - 1 do
   for y = 0, H - 1 do
      local c = t[x][y]
      if c == 1 then selection.set(water, x, y)
      elseif c == 2 then selection.set(rock, x, y)
      elseif c == 3 then selection.set(trees, x, y)
      elseif c == 0 then selection.set(floor, x, y)
      end
   end
end
des.terrain(floor, ".")
des.terrain(water, "}")
des.terrain(rock, " ")
des.terrain(trees, "T")

-- the huts and shrines were drawn before this pass; redraw their floor so
-- the painting above did not disturb them (they only touch cells marked
-- 4/5/6, which none of the selections include)

des.wallify()

-- the whole wilderness is out in the open, in daylight
des.region(selection.area(1, 0, W - 1, H - 1), "lit")

---------------------------------------------------------------------------
-- stairs: up on the western third, down on the eastern third, both on
-- open ground in the main region (flipped half the time)
---------------------------------------------------------------------------
local function pick_spot(xlo, xhi)
   for tries = 1, 400 do
      local x = math.random(xlo, xhi)
      local y = math.random(2, H - 3)
      if t[x][y] == 0 then return x, y end
   end
   return nil
end

local ux, uy = pick_spot(4, math.floor(W / 3))
local dx, dy = pick_spot(math.floor(W * 2 / 3), W - 5)
if percent(50) then ux, uy, dx, dy = dx, dy, ux, uy end
if ux then des.stair("up", ux, uy) else des.stair("up") end
if dx then des.stair("down", dx, dy) else des.stair("down") end

---------------------------------------------------------------------------
-- hut contents: a chest and a guard or two
---------------------------------------------------------------------------
for _, p in ipairs(pois) do
   if p.kind == "hut" then
      local cx = math.random(p.x1, p.x2)
      local cy = math.random(p.y1, p.y2)
      des.object({ id = "chest", x = cx, y = cy })
      if percent(60) then
         des.object({ x = math.random(p.x1, p.x2), y = math.random(p.y1, p.y2) })
      end
      if percent(55) then
         des.monster({ x = math.random(p.x1, p.x2),
                       y = math.random(p.y1, p.y2) })
      end
   else
      if percent(50) then
         des.monster({ class = "@", x = (p.x1 + p.x2) // 2,
                       y = p.y1, peaceful = 1 })
      end
   end
end

---------------------------------------------------------------------------
-- the wild: scattered things to find, and things that find you
---------------------------------------------------------------------------
for i = 1, math.random(24, 34) do des.object() end
for i = 1, math.random(10, 16) do des.object("*") end
for i = 1, math.random(4, 8) do des.object("(") end
for i = 1, math.random(4, 8) do des.object(percent(50) and "%" or "?") end
if percent(75) then
   for i = 1, math.random(2, 6) do des.object("boulder") end
end
des.gold()
des.gold()
des.gold()
des.gold()
des.gold()

for i = 1, math.random(26, 38) do des.monster() end

for i = 1, math.random(8, 14) do des.trap() end
