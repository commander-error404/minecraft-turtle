-- === Paramètres ===
local diamantsCibles = 20
local longueurTunnel = 100 -- longueur du tunnel en blocs

local ressourcesVoulues = {
  ["minecraft:diamond_ore"] = true,
  ["minecraft:iron_ore"] = true,
  ["minecraft:gold_ore"] = true
}

-- === Coordonnées ===
local x, y, z = 0, 0, 0
local direction = 0 -- 0 = nord, 1 = est, 2 = sud, 3 = ouest

-- === Fonctions utilitaires ===
function tournerGauche() direction = (direction - 1) % 4 turtle.turnLeft() end
function tournerDroite() direction = (direction + 1) % 4 turtle.turnRight() end

function avancer()
  while not turtle.forward() do
    turtle.dig()
    sleep(0.5)
  end

  if direction == 0 then z = z - 1
  elseif direction == 1 then x = x + 1
  elseif direction == 2 then z = z + 1
  elseif direction == 3 then x = x - 1 end
end

function monter()
  while not turtle.up() do
    turtle.digUp()
    sleep(0.5)
  end
  y = y + 1
end

function descendre()
  while not turtle.down() do
    turtle.digDown()
    sleep(0.5)
  end
  y = y - 1
end

-- === Compter les diamants ===
function compterDiamants()
  local total = 0
  for i = 1, 16 do
    local item = turtle.getItemDetail(i)
    if item and item.name == "minecraft:diamond" then
      total = total + item.count
    end
  end
  return total
end

-- === Filtrage de l'inventaire ===
function filtrerInventaire()
  for i = 1, 16 do
    local item = turtle.getItemDetail(i)
    if item and not ressourcesVoulues[item.name] and item.name ~= "minecraft:diamond" then
      turtle.select(i)
      turtle.drop() -- jeter les objets non désirés
    end
  end
end

-- === Vérification des blocs et extraction des filons ===
function essayerMiner(fonctionInspection, fonctionAller, fonctionRetour)
  local success, data = fonctionInspection()
  if success and data and ressourcesVoulues[data.name] then
    fonctionAller()
    explorerFilon()
    fonctionRetour()
  end
end

function explorerFilon()
  essayerMiner(turtle.inspect, function() turtle.dig() avancer() end, function() turtle.back() end)
  
  tournerGauche()
  essayerMiner(turtle.inspect, function() turtle.dig() avancer() end, function() turtle.back() end)
  tournerDroite()
  
  tournerDroite()
  essayerMiner(turtle.inspect, function() turtle.dig() avancer() end, function() turtle.back() end)
  tournerGauche()
  
  essayerMiner(turtle.inspectUp, function() turtle.digUp() monter() end, function() descendre() end)
  essayerMiner(turtle.inspectDown, function() turtle.digDown() descendre() end, function() monter() end)
end

-- === Retour à la maison ===
function retourMaison()
  -- Retour en Y
  while y > 0 do descendre() end
  while y < 0 do monter() end

  -- Retour en X
  while x > 0 do
    while direction ~= 3 do tournerGauche() end
    avancer()
  end
  while x < 0 do
    while direction ~= 1 do tournerGauche() end
    avancer()
  end

  -- Retour en Z
  while z > 0 do
    while direction ~= 0 do tournerGauche() end
    avancer()
  end
  while z < 0 do
    while direction ~= 2 do tournerGauche() end
    avancer()
  end
end

-- === Boucle principale ===
print("Début de l'excavation du tunnel...")

for etape = 1, longueurTunnel do
  if compterDiamants() >= diamantsCibles then
    print("20+ diamants trouvés ! Retour à la base...")
    break
  end

  turtle.dig()
  avancer()
  explorerFilon()
  filtrerInventaire()
end

retourMaison()
print("Terminé !")


