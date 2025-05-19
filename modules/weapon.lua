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
    weapon.target = nil          -- inimigo para o qual a arma está mirando
    weapon.orientation = RIGHT   -- orientação da arma
    weapon.rotation = 0          -- rotação da arma em radianos
    weapon.state = IDLE          -- estado atual da arma
    weapon.spriteSheets = {}     -- no tipo imagem do love
    weapon.animations = {}       -- as chaves são estados e os valores são Animações

    return weapon
end

function Weapon:updateOrientation(directions)
    if #directions == 1 then
        self.orientation = directions[1]
    elseif #directions == 2 then
        if tableFind(directions, RIGHT) and tableFind(directions, UP) then
            self.orientation = UP_RIGHT
        elseif tableFind(directions, RIGHT) and tableFind(directions, DOWN) then
            self.orientation = DOWN_RIGHT
        elseif tableFind(directions, LEFT) and tableFind(directions, DOWN) then
            self.orientation = DOWN_LEFT
        elseif tableFind(directions, LEFT) and tableFind(directions, UP) then
            self.orientation = UP_LEFT
        end
    end
    self:updateRotation()
end

function Weapon:updateRotation()
    if self.orientation == UP then
        self.rotation = -math.pi * 0.5
    elseif self.orientation == UP_RIGHT then
        self.rotation = -math.pi * 0.25
    elseif self.orientation == DOWN_RIGHT then
        self.rotation = math.pi * 0.25
    elseif self.orientation == RIGHT then
        self.rotation = 0
    elseif self.orientation == DOWN then
        self.rotation = math.pi * 0.5
    elseif self.orientation == DOWN_LEFT then
        self.rotation = math.pi * 0.75
    elseif self.orientation == LEFT then
        self.rotation = math.pi
    elseif self.orientation == UP_LEFT then
        self.rotation = math.pi * 1.25
    end
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
    return Weapon.new(SLING_SHOT, 20, 5, 1.6, 1, 380, Weapon.slowProjectileAttack, color)
end