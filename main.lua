-- roomMiner.lua
-- Использование: roomMiner <length> <halfWidth> <height>
-- length: сколько блоков вперед
-- halfWidth: сколько блоков вправо и влево (итого ширина = halfWidth*2 + 1)
-- height: сколько блоков вверх (включая стартовый уровень)

local args = { ... }
if #args < 3 then
    print("Использование: roomMiner <длина> <половина ширины> <высота>")
    return
end

local length = tonumber(args[1])
local halfWidth = tonumber(args[2])
local height = tonumber(args[3])

if not length or not halfWidth or not height then
    print("Все параметры должны быть числами")
    return
end

-- === СЛЕЖЕНИЕ ЗА ПОЗИЦИЕЙ ===
local pos = {x=0, y=0, z=0}
local dir = 0 -- 0=+Z(вперед), 1=+X(вправо), 2=-Z(назад), 3=-X(влево)

local function turnRight()
    turtle.turnRight()
    dir = (dir+1)%4
end
local function turnLeft()
    turtle.turnLeft()
    dir = (dir+3)%4
end
local function turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
    dir = (dir+2)%4
end

local function tryDig() while turtle.detect() do turtle.dig() end end
local function tryDigUp() while turtle.detectUp() do turtle.digUp() end end
local function tryDigDown() while turtle.detectDown() do turtle.digDown() end end

local function safeForward()
    tryDig()
    if turtle.forward() then
        if dir==0 then pos.z = pos.z+1
        elseif dir==1 then pos.x = pos.x+1
        elseif dir==2 then pos.z = pos.z-1
        elseif dir==3 then pos.x = pos.x-1 end
        return true
    end
    return false
end

local function safeUp()
    tryDigUp()
    if turtle.up() then
        pos.y = pos.y+1
        return true
    end
    return false
end

local function safeDown()
    tryDigDown()
    if turtle.down() then
        pos.y = pos.y-1
        return true
    end
    return false
end

-- === ВОЗВРАТ К СТАРТУ ===
local function goTo(x,y,z)
    -- Сначала по Y (вверх/вниз)
    while pos.y < y do safeUp() end
    while pos.y > y do safeDown() end
    -- Потом по X
    if pos.x < x then
        while dir ~= 1 do turnRight() end
        while pos.x < x do safeForward() end
    elseif pos.x > x then
        while dir ~= 3 do turnRight() end
        while pos.x > x do safeForward() end
    end
    -- Потом по Z
    if pos.z < z then
        while dir ~= 0 do turnRight() end
        while pos.z < z do safeForward() end
    elseif pos.z > z then
        while dir ~= 2 do turnRight() end
        while pos.z > z do safeForward() end
    end
end

local function dumpInventory()
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

-- Храним точку остановки
local savedPos = nil
local savedDir = nil

local function checkInventory()
    for i=1,16 do
        if turtle.getItemCount(i) == 0 then return end
    end
    print("Инвентарь полон, возвращаемся...")
    -- запомнить место
    savedPos = {x=pos.x, y=pos.y, z=pos.z}
    savedDir = dir
    -- вернуться домой
    goTo(0,0,0)
    dumpInventory()
    -- вернуться обратно
    print("Возвращаемся к работе...")
    goTo(savedPos.x, savedPos.y, savedPos.z)
    while dir ~= savedDir do turnRight() end
end

-- === ОСНОВНОЙ АЛГОРИТМ ===
for h=1,height do
    if h > 1 then safeUp() end
    for l=1,length do
        -- копаем влево
        turnLeft()
        for w=1,halfWidth do
            safeForward()
            tryDigUp()
            tryDigDown()
            checkInventory()
        end
        -- вернуться в центр
        turnAround()
        for w=1,halfWidth do safeForward() end
        turnLeft()

        -- копаем вправо
        turnRight()
        for w=1,halfWidth do
            safeForward()
            tryDigUp()
            tryDigDown()
            checkInventory()
        end
        -- вернуться в центр
        turnAround()
        for w=1,halfWidth do safeForward() end
        turnRight()

        -- если не последний ряд длины
        if l < length then
            safeForward()
            tryDigUp()
            tryDigDown()
            checkInventory()
        end
    end
    -- вернуться в начало длины
    turnAround()
    for l=1,length-1 do safeForward() end
    turnAround()
end

-- Возврат домой по окончании
goTo(0,0,0)
dumpInventory()
print("Комната готова!")


