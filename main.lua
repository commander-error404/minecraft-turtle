-- roomMiner.lua
-- Utilisation: roomMiner <longueur> <demiLargeur> <hauteur>
-- longueur: combien de blocs en avant
-- demiLargeur: combien de blocs à gauche et à droite (largeur totale = demiLargeur*2 + 1)
-- hauteur: combien de blocs vers le haut (y compris le niveau de départ)

local args = { ... }
if #args < 3 then
    print("Usage: roomMiner <longueur> <demiLargeur> <hauteur>")
    return
end

local longueur = tonumber(args[1])
local demiLargeur = tonumber(args[2])
local hauteur = tonumber(args[3])

if not longueur or not demiLargeur or not hauteur then
    print("Tous les paramètres doivent être des nombres")
    return
end

-- === PARAMÈTRES ===
local minFuel = 50   -- niveau minimum de carburant
local keepItems = {["minecraft:coal"]=true, ["minecraft:charcoal"]=true} -- ne pas jeter

-- === SUIVI DE POSITION ===
local pos = {x=0, y=0, z=0}
local dir = 0 -- 0=+Z(avant), 1=+X(droite), 2=-Z(arrière), 3=-X(gauche)

local function turnRight() turtle.turnRight() dir = (dir+1)%4 end
local function turnLeft() turtle.turnLeft() dir = (dir+3)%4 end
local function turnAround() turtle.turnLeft() turtle.turnLeft() dir = (dir+2)%4 end

local function tryDig() while turtle.detect() do turtle.dig() end end
local function tryDigUp() while turtle.detectUp() do turtle.digUp() end end
local function tryDigDown() while turtle.detectDown() do turtle.digDown() end end

-- === CARBURANT ===
local function refuelIfNeeded()
    if turtle.getFuelLevel() == "unlimited" then return end
    if turtle.getFuelLevel() > minFuel then return end
    for i=1,16 do
        local item = turtle.getItemDetail(i)
        if item and (item.name == "minecraft:coal" or item.name == "minecraft:charcoal") then
            turtle.select(i)
            if turtle.refuel(1) then
                print("Rechargement avec du charbon... Carburant: "..turtle.getFuelLevel())
                return
            end
        end
    end
    print("⚠ Pas de carburant! Ajoutez du charbon dans l'inventaire!")
end

-- === DÉPLACEMENT ===
local function safeForward()
    refuelIfNeeded()
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
    refuelIfNeeded()
    tryDigUp()
    if turtle.up() then pos.y = pos.y+1 return true end
    return false
end

local function safeDown()
    refuelIfNeeded()
    tryDigDown()
    if turtle.down() then pos.y = pos.y-1 return true end
    return false
end

-- === RETOUR À LA BASE ===
local function goTo(x,y,z)
    while pos.y < y do safeUp() end
    while pos.y > y do safeDown() end
    if pos.x < x then while dir ~= 1 do turnRight() end while pos.x < x do safeForward() end
    elseif pos.x > x then while dir ~= 3 do turnRight() end while pos.x > x do safeForward() end end
    if pos.z < z then while dir ~= 0 do turnRight() end while pos.z < z do safeForward() end
    elseif pos.z > z then while dir ~= 2 do turnRight() end while pos.z > z do safeForward() end end
end

-- === INVENTAIRE ===
local savedPos, savedDir

local function dumpInventory()
    for i=1,16 do
        local item = turtle.getItemDetail(i)
        if item and not keepItems[item.name] then
            turtle.select(i)
            turtle.drop()
        end
    end
    turtle.select(1)
end

local function checkInventory()
    for i=1,16 do
        if turtle.getItemCount(i) == 0 then return end
    end
    print("Inventaire plein, retour à la base...")
    savedPos = {x=pos.x, y=pos.y, z=pos.z}
    savedDir = dir
    goTo(0,0,0)
    dumpInventory()
    print("Retour au travail...")
    goTo(savedPos.x, savedPos.y, savedPos.z)
    while dir ~= savedDir do turnRight() end
end

-- === ALGORITHME PRINCIPAL ===
for h=1,hauteur do
    if h > 1 then safeUp() end
    for l=1,longueur do
        -- à gauche
        turnLeft()
        for w=1,demiLargeur do safeForward() tryDigUp() tryDigDown() checkInventory() end
        turnAround()
        for w=1,demiLargeur do safeForward() end
        turnLeft()

        -- à droite
        turnRight()
        for w=1,demiLargeur do safeForward() tryDigUp() tryDigDown() checkInventory() end
        turnAround()
        for w=1,demiLargeur do safeForward() end
        turnRight()

        if l < longueur then safeForward() tryDigUp() tryDigDown() checkInventory() end
    end
    turnAround()
    for l=1,longueur-1 do safeForward() end
    turnAround()
end

-- Retour final à la base
goTo(0,0,0)
dumpInventory()
print("Salle terminée!")


