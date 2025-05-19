----------------------------------------
-- Variáveis e Enums
----------------------------------------
KATANA = "Katana"
SLING_SHOT = "Sling Shot"

----------------------------------------
-- Classe Weapon
----------------------------------------
Weapon = {}
Weapon.__index = Weapon

function Weapon.new(type, damage, ammo, cadence, cooldown, range, attack, color)
    local weapon = setmetatable({}, Weapon)

    -- atributos que variam
    weapon.type = type             -- nome do tipo de arma
    weapon.damage = damage         -- dano
    weapon.ammo = ammo             -- número de munições
    weapon.cadence = cadence       -- número máximo de ataques por segundo
    weapon.cooldown = cooldown     -- tempo de recarga
    weapon.range = range           -- alcance
    weapon.attack = attack         -- método de ataque
    weapon.color = color           -- cor da arma
    -- atributos fixos na instanciação
    weapon.size = {height = 20, width = 64}
    weapon.target = nil
    weapon.orientation = 0   -- orientação da arma
    weapon.state = IDLE      -- estado atual da arma
    weapon.spriteSheets = {} -- no tipo imagem do love
    weapon.animations = {}   -- as chaves são estados e os valores são Animações

    return weapon
end

----------------------------------------
-- Funções de Ataque
----------------------------------------
function Weapon:meleeAtack()
    print("MELEE ATTACK")
end

function Weapon:slowProjectileAttack()
    print("SLOW PROJECTILE ATTACK")
end

----------------------------------------
-- Funções Globais
----------------------------------------
function newWeapon(type)
    if type == KATANA then
        return newKatana()
    elseif type == SLING_SHOT then
        return newSlingShot()
    end
end

function newKatana()
    local color = {r = 0.9, g = 0.9, b = 0.9, a = 1.0}
    return Weapon.new(KATANA, 30, math.huge, 1, 0, 120, Weapon.meleeAtack, color)
end

function newSlingShot()
    local color = {r = 0.7, g = 0.7, b = 0.4, a = 1.0}
    return Weapon.new(SLING_SHOT, 20, 5, 1.6, 1, 380, Weapon.slowProjectileAtack, color)
end