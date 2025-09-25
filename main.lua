-- === Настройки / Settings ===
local targetDiamonds = 20
local tunnelLength = 100 -- длина туннеля в блоках / tunnel length in blocks

local wanted = {
  ["minecraft:diamond_ore"] = true,
  ["minecraft:iron_ore"] = true,
  ["minecraft:gold_ore"] = true
}

-- === Переменные для координат / Coordinate variables ===
local x, y, z = 0, 0, 0
local dir = 0 -- 0 = north/nord, 1 = east/est, 2 = south/sud, 3 = west/ouest

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

function up()
  while not turtle.up() do turtle.digUp() sleep(0.5) end
  y = y + 1
end

function down()
  while not turtle.down() do turtle.digDown() sleep(0.5) end
  y = y - 1
end

-- === Подсчёт алмазов / Count diamonds ===
function countDiamonds()
  local total = 0
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item and item.name == "minecraft:diamond" then
      total = total + item.count
    end
  end
  return total
end

-- === Фильтрация инвентаря / Inventory filtering ===
function filterInventory()
  for i=1,16 do
    local item = turtle.getItemDetail(i)
    if item and not wanted[item.name] and item.name ~= "minecraft:diamond" then
      turtle.select(i)
      turtle.drop() -- выкинуть ненужное / drop unwanted items
    end
  end
end

-- === Проверка блока и добыча жилы / Check block and mine vein ===
function tryMine(dirCheck, moveFunc, backFunc)
  local success, data = dirCheck()
  if success and data and wanted[data.name] then
    moveFunc()
    exploreOre()
    backFunc()
  end
end

function exploreOre()
  tryMine(turtle.inspect, function() turtle.dig() forward() end, function() turtle.back() end)
  turnLeft(); tryMine(turtle.inspect, function() turtle.dig() forward() end, function() turtle.back() end); turnRight()
  turnRight(); tryMine(turtle.inspect, function() turtle.dig() forward() end, function() turtle.back() end); turnLeft()
  tryMine(turtle.inspectUp, function() turtle.digUp() up() end, function() down() end)
  tryMine(turtle.inspectDown, function() turtle.digDown() down() end, function() up() end)
end

-- === Возврат домой / Return home ===
function goHome()
  -- возвращаемся по Y / go back along Y
  while y > 0 do down() end
  while y < 0 do up() end
  -- возвращаемся по X / go back along X
  while x > 0 do
    while dir ~= 3 do turnLeft() end
    forward()
  end
  while x < 0 do
    while dir ~= 1 do turnLeft() end
    forward()
  end
  -- возвращаемся по Z / go back along Z
  while z > 0 do
    while dir ~= 0 do turnLeft() end
    forward()
  end
  while z < 0 do
    while dir ~= 2 do turnLeft() end
    forward()
  end
end

-- === Основной цикл / Main loop ===
print("Начинаем копать туннель... / Starting tunnel excavation...")

for step = 1, tunnelLength do
  if countDiamonds() >= targetDiamonds then
    print("20+ алмазов найдено! Возвращаемся домой... / 20+ diamonds found! Returning home...")
    break
  end

  turtle.dig()
  forward()
  exploreOre()
  filterInventory()
end

goHome()
print("Готово! / Done!")

