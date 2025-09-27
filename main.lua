-- Tortue de minage : creuser un parallélépipède
-- Paramètres : largeur (selon X), longueur (selon Z), hauteur (selon Y)
-- Valeurs positives : vers l'avant, vers la droite, vers le haut

-- Exemple d'exécution :
--   mineArea 5 4 3
-- signifie : largeur = 5, longueur = 4, hauteur = 3 — à partir du point de départ, monter de 3 blocs, largeur vers la droite, longueur vers l'avant

-- Vérification et traitement des arguments
local args = { ... }
if #args < 3 then
  print("Utilisation : mineArea <largeur_X> <longueur_Z> <hauteur_Y>")
  return
end

local largeur = tonumber(args[1])
local longueur = tonumber(args[2])
local hauteur = tonumber(args[3])

if not largeur or not longueur or not hauteur then
  print("Les arguments doivent être des nombres.")
  return
end

-- Fonction : creuse si nécessaire et avance
local function essayerDeCreuser()
  while turtle.detect() do
    turtle.dig()
  end
end

local function essayerDeCreuserHaut()
  while turtle.detectUp() do
    turtle.digUp()
  end
end

local function essayerDeCreuserBas()
  while turtle.detectDown() do
    turtle.digDown()
  end
end

-- Fonctions de déplacement sécurisé avec creusage
local function monterEnSécurité()
  essayerDeCreuserHaut()
  turtle.up()
end

local function descendreEnSécurité()
  essayerDeCreuserBas()
  turtle.down()
end

local function avancerEnSécurité()
  essayerDeCreuser()
  turtle.forward()
end

-- Procédure principale : creuser couche par couche en hauteur, puis lignes et colonnes
local pasY = hauteur > 0 and 1 or -1
local couches = math.abs(hauteur)

for h = 1, couches do
  -- Monter ou descendre d’un niveau sauf au début
  if h > 1 then
    if pasY == 1 then
      monterEnSécurité()
    else
      descendreEnSécurité()
    end
  end

  -- Creuser un rectangle de largeur x longueur à ce niveau
  for l = 1, longueur do
    for w = 1, largeur do
      if not (l == 1 and w == 1) then
        if (l % 2 == 1) then
          -- Ligne impaire : déplacement vers la droite
          if w > 1 then
            essayerDeCreuser()
            turtle.turnRight()
            avancerEnSécurité()
            turtle.turnLeft()
          end
        else
          -- Ligne paire : déplacement vers la gauche
          if w > 1 then
            essayerDeCreuser()
            turtle.turnLeft()
            avancerEnSécurité()
            turtle.turnRight()
          end
        end
      end
    end
    -- Aller à la ligne suivante si ce n’est pas la dernière
    if l < longueur then
      avancerEnSécurité()
    end
  end

  -- Revenir à la position d’origine (coin du parallélépipède)
  if longueur > 1 then
    for i = 1, (longueur - 1) do
      turtle.back()
    end
  end

  if (longueur % 2 == 0) then
    -- Si nombre pair de lignes, revenir par la largeur
    for i = 1, (largeur - 1) do
      turtle.turnRight()
      avancerEnSécurité()
      turtle.turnLeft()
    end
  end
  -- Sinon, déjà au bon endroit, rien à faire

  -- Remise de l'orientation (simplifiée)
end

print("Opération terminée.")
