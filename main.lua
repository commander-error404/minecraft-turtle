-- Script intelligent de minage pour tortue
-- Descend à l'altitude optimale (Y), effectue du branch mining et vein mining,
-- filtre l’inventaire (diamants/or/fer) et rentre à la base après avoir trouvé 20 diamants.

-- Paramètres
local DIAMANTS_CIBLES = 20
local ECART_BRANCHES = 3        -- distance entre les branches
local LONGUEUR_TUNNEL = 50     -- longueur du tunnel principal

local FILTRE_MINERAIS = {
  ["minecraft:diamond_ore"] = true,
  ["minecraft:iron_ore"]    = true,
  ["minecraft:gold_ore"]    = true,
}

-- Profondeurs optimales pour les minerais (Y)
local NIVEAU_OPTIMAL = {
  ["minecraft:diamond_ore"] = -59,
  ["minecraft:iron_ore"]    = 50,
  ["minecraft:gold_ore"]    = 48,
}

-- Obtenir l'altitude actuelle (via GPS ou autre)
local function getCurrentY()
  local _, y, _ = gps.locate()
  return math.floor(y)
end

-- Monter/descendre la tortue jusqu'à l'altitude cible
local function goToLevel(targetY)
  local currentY = getCurrentY()
  while currentY < targetY do
    turtle.up()
    currentY = currentY + 1
  end
  while currentY > targetY do
    turtle.down()
    currentY = currentY - 1
  end
end

-- Compter les diamants dans l’inventaire
local function countDiamonds()
  local total = 0
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and item.name == "minecraft:diamond" then
      total = total + item.count
    end
  end
  return total
end

-- Vérifie si un bloc est précieux (dans la liste)
local function isValuable(name)
  return FILTRE_MINERAIS[name] or false
end

-- Extraction récursive d’un filon de minerai
local function mineVein()
  for _, dir in ipairs({"forward", "up", "down", "left", "right"}) do
    local success, data
    if dir == "forward" then
      success, data = turtle.inspect()
    elseif dir == "up" then
      success, data = turtle.inspectUp()
    elseif dir == "down" then
      success, data = turtle.inspectDown()
    elseif dir == "left" then
      turtle.turnLeft()
      success, data = turtle.inspect()
      turtle.turnRight()
    elseif dir == "right" then
      turtle.turnRight()
      success, data = turtle.inspect()
      turtle.turnLeft()
    end

    if success and isValuable(data.name) then
      if dir == "forward" then turtle.dig(); turtle.forward()
      elseif dir == "up"    then turtle.digUp(); turtle.up()
      elseif dir == "down"  then turtle.digDown(); turtle.down()
      elseif dir == "left"  then turtle.turnLeft(); turtle.dig(); turtle.forward(); turtle.turnRight()
      elseif dir == "right" then turtle.turnRight(); turtle.dig(); turtle.forward(); turtle.turnLeft()
      end

      mineVein() -- appel récursif pour continuer le filon

      -- Revenir en arrière après avoir extrait le filon
      if dir == "forward" then turtle.back()
      elseif dir == "up"    then turtle.down()
      elseif dir == "down"  then turtle.up()
      elseif dir == "left"  then turtle.turnLeft(); turtle.back(); turtle.turnRight()
      elseif dir == "right" then turtle.turnRight(); turtle.back(); turtle.turnLeft()
      end
    end
  end
end

-- Filtrer l’inventaire : ne garder que les ressources utiles
local function filterInventory()
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and not (
      item.name == "minecraft:diamond" or
      item.name == "minecraft:iron_ingot" or
      item.name == "minecraft:gold_ingot"
    ) then
      turtle.select(slot)
      turtle.drop() -- jeter dans un coffre si possible, sinon supprimer
    end
  end
  turtle.select(1) -- revenir au slot 1
end

-- Retour à la base et déchargement
local function returnHome()
  print("Objectif atteint, retour à la base...")
  -- Ici, ajouter la logique de retour (GPS ou retour manuel)
  -- Ex. : turtle.back() en boucle ou navigation par coordonnées
  -- Après retour :
  filterInventory()
  print("Déchargement terminé.")
  error() -- arrêter le programme
end

-- Fonction principale de branch mining
local function branchMine()
  for branch = 0, ECART_BRANCHES - 1 do
    -- Creuser le tunnel principal
    for step = 1, LONGUEUR_TUNNEL do
      local success, data = turtle.inspect()
      if success and isValuable(data.name) then
        turtle.dig()
        turtle.forward()
        mineVein()
        turtle.back()
      else
        turtle.dig()
        turtle.forward()
      end

      -- Vérifie si l’objectif diamant est atteint
      if countDiamonds() >= DIAMANTS_CIBLES then
        returnHome()
      end
    end

    -- Se déplacer pour creuser une nouvelle branche
    if branch < ECART_BRANCHES - 1 then
      if branch % 2 == 0 then
        turtle.turnRight()
        turtle.dig()
        turtle.forward()
        turtle.turnRight()
      else
        turtle.turnLeft()
        turtle.dig()
        turtle.forward()
        turtle.turnLeft()
      end
    end
  end
end

-- Lancer le script
print("Je monte au niveau optimal pour les diamants :", NIVEAU_OPTIMAL["minecraft:diamond_ore"])
goToLevel(NIVEAU_OPTIMAL["minecraft:diamond_ore"])
print("Début du branch mining...")
branchMine()
