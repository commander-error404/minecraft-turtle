-- Mining Turtle: копание параллелепипеда
-- Параметры: ширина (по X), длина (по Z), высота (по Y)
-- Положительные значения: вперед, вправо, вверх

-- Пример запуска:
--   mineArea 5 4 3
-- это значит: ширина 5, длина 4, высота 3 — от стартовой точки вверх 3, ширина вправо 5, вперед 4

-- Проверка и обработка аргументов
local args = { ... }
if #args < 3 then
  print("Использование: mineArea <ширина_X> <длина_Z> <высота_Y>")
  return
end

local width = tonumber(args[1])
local length = tonumber(args[2])
local height = tonumber(args[3])

if not width or not length or not height then
  print("Аргументы должны быть числами.")
  return
end

-- Функция: при необходимости dig/digUp/digDown, move вперёд/вверх/вниз
local function tryDig()
  while turtle.detect() do
    turtle.dig()
  end
end

local function tryDigUp()
  while turtle.detectUp() do
    turtle.digUp()
  end
end

local function tryDigDown()
  while turtle.detectDown() do
    turtle.digDown()
  end
end

-- Функции перемещения с копанием
local function safeUp()
  tryDigUp()
  turtle.up()
end

local function safeDown()
  tryDigDown()
  turtle.down()
end

local function safeForward()
  tryDig()
  turtle.forward()
end

-- Основная процедура: копаем позиции по высоте, затем по длине, по ширине
-- Будем копать слой за слоем по высоте

local originY = 0  -- начало уровня
local stepY = height > 0 and 1 or -1
local layers = math.abs(height)

for h = 1, layers do
  -- Двигаемся вверх или вниз на один уровень (кроме первого слоя, если h==1, мы уже на уровне старта)
  if h > 1 then
    if stepY == 1 then
      safeUp()
    else
      safeDown()
    end
  end

  -- Для этого слоя, копаем прямоугольник width x length
  for l = 1, length do
    for w = 1, width do
      -- На первой клетке этого слоя (l,w) мы уже стоим, так что не двигаемся
      if not (l == 1 and w == 1) then
        -- Если не на первой в строке, передвигаемся вправо (или влево) в зависимости от чётности строк
        -- Делаем змейкой, чтобы экономить перемещения
        if (l % 2 == 1) then
          -- нечётный ряд: движемся вправо
          if w > 1 then
            tryDig()
            turtle.turnRight()
            safeForward()
            turtle.turnLeft()
          end
        else
          -- чётный ряд: движемся влево
          if w > 1 then
            tryDig()
            turtle.turnLeft()
            safeForward()
            turtle.turnRight()
          end
        end
      end
    end
    -- После окончания ряда ширины, если это не последний ряд длины, переходим на следующий ряд
    if l < length then
      safeForward()
    end
  end

  -- После слоя, возвращаемся к начальной позиции по ширине и длине, чтобы начать следующий слой
  -- Сначала вернуть обратно по длине
  if length > 1 then
    -- плавно возвращаемся к начальной линии длины
    for i = 1, (length - 1) do
      turtle.back()
    end
  end
  -- Затем по ширине: в зависимости от того, на каком конце мы оказались
  if (length % 2 == 0) then
    -- если чётное число рядов, то мы на другой стороне от начала ширины
    for i = 1, (width - 1) do
      -- поворот, движение назад, поворот обратно
      turtle.turnRight()
      safeForward()
      turtle.turnLeft()
    end
  else
    -- если нечётное — мы уже на начале по ширине
    -- нет необходимости
  end

  -- После этого поворачиваем так, чтобы взгляд был направлен в сторону "вперёд" исходную
  -- Например, если last turn был поворот, то надо вернуть ориентацию
  -- Для простоты: поворачиваем к первоначальной ориентации
  -- Можно реализовать track направления, но здесь упрощение

end

print("Работа завершена.")

