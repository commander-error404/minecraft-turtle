-- mineArea.lua
-- Использование: mineArea <width> <length> <height>

local args = { ... }
if #args < 3 then
    print("Использование: mineArea <ширина> <длина> <высота>")
    return
end

local width  = tonumber(args[1])
local length = tonumber(args[2])
local height = tonumber(args[3])

if not width or not length or not height then
    print("Аргументы должны быть числами")
    return
end

-- вспомогательные функции
local function digForward()
    while turtle.detect() do
        turtle.dig()
    end
    turtle.forward()
end

local function digUp()
    while turtle.detectUp() do
        turtle.digUp()
    end
    turtle.up()
end

local function digDown()
    while turtle.detectDown() do
        turtle.digDown()
    end
    turtle.down()
end

-- копаем по слоям
for h = 1, height do
    for l = 1, length do
        for w = 1, width - 1 do
            digForward()
        end
        -- если не последний ряд – возвращаемся и смещаемся
        if l < length then
            if l % 2 == 1 then
                turtle.turnRight()
                digForward()
                turtle.turnRight()
            else
                turtle.turnLeft()
                digForward()
                turtle.turnLeft()
            end
        end
    end
    -- подняться на следующий слой
    if h < height then
        digUp()
        turtle.turnRight()
        turtle.turnRight()
    end
end

print("Готово!")
