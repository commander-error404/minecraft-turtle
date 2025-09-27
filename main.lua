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

-- стартовые координаты
local startX, startY, startZ = 0, 0, 0
local dir = 0 -- 0=вперед, 1=право, 2=назад, 3=лево

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===
local function tryDig() while turtle.detect() do turtle.dig() end end
local function tryDigUp() while turtle.detectUp() do turtle.digUp() end end
local function tryDigDown() while turtle.detectDown() do turtle.digDown() end end

local function safeForward()
    tryDig()
    turtle.forward()
end
local function safeUp()
    tryDigUp()
    turtle.up()
end
local function safeDown()
    tryDigDown()
    turtle.down()
end

local function turnRight() turtle.turnRight() dir = (dir+1)%4 end
local function turnLeft() turtle.turnLeft() dir = (dir+3)%4 end
local function turnAround() turtle.turnLeft() turtle.turnLeft() dir = (dir+2)%4 end

-- Проверка инвентаря: если заполнен → вернуться, выложить в сундук
local function checkInventory()
    for i=1,16 do
        if turtle.getItemCount(i) == 0 then
            return
        end
    end
    print("Инвентарь полон, выгружаем...")
    returnToStart()
    dumpInventory()
    goBackToWork()
end

function dumpInventory()
    for i=1,16 do
        turtle.select(i)
        turtle.drop()
    end
    turtle.select(1)
end

-- TODO: хранение координат и возврат к месту работы.
-- Для простоты пока не реализовано, можно добавить лог.
-- Сейчас он просто остановится у сундука.
function returnToStart()
    print("Возвращение к старту...")
    -- !! Для полной версии нужно вести координаты перемещений
end

function goBackToWork()
    print("Возвращение к работе...")
    -- !! Для полной версии нужно восстановить позицию
end

-- === ОСНОВНОЙ АЛГОРИТМ ===
for h=1,height do
    -- слой по высоте
    if h > 1 then safeUp() end

    for l=1,length do
        -- копаем ряд ширины: сначала влево
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
        turnLeft() -- снова лицом вперёд

        -- теперь вправо
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
        turnRight() -- снова лицом вперёд

        -- если это не последний ряд длины → двигаемся вперед
        if l < length then
            safeForward()
            tryDigUp()
            tryDigDown()
            checkInventory()
        end
    end

    -- вернуться в начало длины
    turnAround()
    for l=1,length-1 do turtle.forward() end
    turnAround()
end

print("Комната готова!")

