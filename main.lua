-- Script intelligent de minage pour tortue
-- Descend ou monte à l'altitude Y spécifiée, fait du branch mining et vein mining,
-- filtre l’inventaire (diamants/or/fer), puis retourne à la base après avoir atteint l’objectif.

-- Paramètres
local CIBLE_DIAMANTS = 20       -- objectif de diamants
local ECART_BRANCHES = 3        -- espacement entre les branches latérales
local LONGUEUR_TUNNEL = 50      -- longueur du tunnel principal

local FILTRE_MINERAIS = {       -- minerais à extraire
  ["minecraft:diamond_ore"] = true,
  ["minecraft:iron_ore"]    = true,
  ["minecraft:gold_ore"]    = true,
}

-- Fonction utilitaire : demande un nombre via le chat
local function demanderNiveau(message)
  print(message)
  while true do
    local event, input = os.pullEvent("chat")
    local niveau = tonumber(input)
    if niveau then
      print("Niveau entré :", niveau)
      return niveau
    else
      print("Erreur : entrée invalide. Veuillez entrer un nombre.")
    end
  end
end

-- Demander les niveaux
local niveauActuel = demanderNiveau("Entrez le niveau Y actuel (ex. : où se trouve le coffre) :")
local niveauCible  = demanderNiveau("Entrez le niveau Y de minage (ex. : -59 pour les diamants) :")

-- Monter/descendre jusqu'au bon niveau
local function allerAuNiveau()
  while niveauActuel < niveauCible do
    turtle.up()
    niveauActuel = niveauActuel + 1
  end
  while niveauActuel > niveauCible do
    turtle.down()
    niveauActuel = niveauActuel - 1
  end
  print("Niveau Y atteint :", niveauActuel)
end

-- Compter les diamants dans l’inventaire
local function compterDiamants()
  local total = 0
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item and item.name == "minecraft:diamond" then
      total = total + item.count
    end
  end
  return total
end

-- Vérifie si un bloc est un minerai précieux
local function estPrecieux(nom)
  return FILTRE_MINERAIS[nom] or false
end

-- Minage récursif d’un filon
local function minerFilon()
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

    if success and estPrecieux(data.name) then
      -- Miner le bloc et avancer dedans
      if dir == "forward" then turtle.dig(); turtle.forward()
      elseif dir == "up"    then turtle.digUp(); turtle.up()
      elseif dir == "down"  then turtle.digDown(); turtle.down()
      elseif dir == "left"  then turtle.turnLeft(); turtle.dig(); turtle.forward(); turtle.turnRight()
      elseif dir == "right" then turtle.turnRight(); turtle.dig(); turtle.forward(); turtle.turnLeft()
      end

      -- Appel récursif pour continuer le filon
      minerFilon()

      -- Retour en arrière
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
local function filtrerInventaire()
  for slot = 1, 16 do
    local item = turtle.getItemDetail(slot)
    if item then
      local nom = item.name
      -- Seuls les diamants, lingots de fer et d’or sont gardés
      if not (nom == "minecraft:diamond" or nom == "minecraft:iron_ingot" or nom == "minecraft:gold_ingot") then
        turtle.select(slot)
        turtle.drop()
      end
    end
  end
  turtle.select(1)
end

-- Retour à la base et déchargement
local function retourMaison()
  print("Objectif atteint ("..compterDiamants().." diamants). Retour à la base...")
  -- Retour simple : reculer tout le tunnel
  for i = 1, LONGUEUR_TUNNEL do
    turtle.back()
  end
  -- Filtrer et déposer dans le coffre
  filtrerInventaire()
  print("Déchargement terminé.")
  error() -- arrêter l’exécution
end

-- Fonction principale de branch mining
local function branchMining()
  for branche = 0, ECART_BRANCHES - 1 do
    -- Creuser le tunnel principal
    for etape = 1, LONGUEUR_TUNNEL do
      local success, data = turtle.inspect()
      if success and estPrecieux(data.name) then
        turtle.dig()
        turtle.forward()
        minerFilon()
        turtle.back()
      else
        turtle.dig()
        turtle.forward()
      end

      -- Vérifier si l'objectif est atteint
      if compterDiamants() >= CIBLE_DIAMANTS then
        retourMaison()
      end
    end

    -- Se déplacer latéralement pour commencer une nouvelle branche
    if branche < ECART_BRANCHES - 1 then
      if (branche % 2) == 0 then
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

-- Démarrage du script
print("Montée/descente vers le niveau Y =", niveauCible)
allerAuNiveau()
print("Début du branch mining avec vein mining...")
branchMining()
