-- === Настройки / Settings ===
local targetDiamonds = 20
local maxTunnelLength = 100
local branchSpacing = 3 -- расстояние между боковыми туннелями
local wanted = {
  ["minecraft:diamond_ore"] = true,
  ["minecraft:gold_ore"] = true,
  ["minecraft:iron_ore"] = true
}

local diamondY = 10 -- рекомендуемый уровень алмазов
local goldY = 20
local ironY = 32

-- === Координаты и направление / Coordinates & direction ===
local x, y, z = 0, 0, 0
local dir = 0 -- 0=north,1=east,2=south,3=west

-- === Вспомогательные функции / Helper functions ===
function turnLeft() dir = (dir - 1) % 4 turtle.turnLeft() end
function turnRight() dir = (dir + 1) % 4 turtle.turnRight() end

function forward()
  while not turtle.forward() do turtle.dig() sleep(0.5) end
  if dir == 0 then z = z - 1
  elseif dir == 1 then x = x + 1
  elseif dir == 2 then z = z + 1
  elseif dir == 3 then x = x - 1 end
end

function back()
  turtle.back()
  if dir == 0 then z = z + 1
  elseif dir == 1 then x = x - 1
  elseif dir == 2 then z = z - 1
  elseif dir == 3 then x = x + 1 end
end

function up()
  while not turtle.up() do turtle.digUp() sleep(0.5) end
  y = y + 1
end

function down()
  while not turtle.down() do turtle.digDown() sleep(0.5) end
  y = y - 1
end

-- === Умный выбор уровня для руды / Smart Y-level selection ===
function goToY(ore)
  local target
  if ore == "minecraft:diamond_ore" then target = diamondY
  elseif ore == "minecraft:gold_ore" then target = goldY
  elseif ore == "minecraft:iron_ore" then target = ironY
  else return end
  while y > target do down() end
  while y < target do up() end
end

-- === Подсчёт алмазов / Count diamonds ===
function countDiamonds()
  local total = 0
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item and item.name == "minecraft:diamond" then total = total + item.count end
  end
  return total
end

-- === Фильтрация инвентаря / Inventory filtering ===
function filterInventory()
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item and not wanted[item.name] then
      turtle.select(i)
      turtle.drop() -- выбросить ненужное / drop unwanted
    end
  end
end

-- === Vein Mining / рекурсивная добыча жилы руды ===
function veinMine()
  local directions = {
    {check=turtle.inspect, dig=turtle.dig, move=forward, back=back},
    {check=turtle.inspectUp, dig=turtle.digUp, move=up, back=down},
    {check=turtle.inspectDown, dig=turtle.digDown, move=down, back=up}
  }

  for _, d in ipairs(directions) do
    local success, data = d.check()
    if success and data and wanted[data.name] then
      d.dig()
      d.move()
      veinMine() -- рекурсивно добываем жилу
      d.back()
    end
  end


