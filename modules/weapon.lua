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

function Weapon.new(type, damage, ammo, cadence, cooldown, range, attack, color, particles)
	local weapon = setmetatable({}, Weapon)

	-- atributos que variam
	weapon.type = type -- nome do tipo de arma
	weapon.damage = damage -- dano
	weapon.ammo = ammo -- número de munições
	weapon.cadence = cadence -- número máximo de ataques por segundo
	weapon.cooldown = cooldown -- tempo de recarga
	weapon.range = range -- alcance
	weapon.attack = attack -- método de ataque
	weapon.color = color -- cor da arma
	weapon.attackParticles = particles
	-- atributos fixos na instanciação
	weapon.size = { height = 20, width = 64 }
	weapon.target = nil -- inimigo para o qual a arma está mirando
	weapon.rotation = 0 -- rotação da arma em radianos
	weapon.state = IDLE -- estado atual da arma
	weapon.spriteSheets = {} -- no tipo imagem do love
	weapon.animations = {} -- as chaves são estados e os valores são Animações

	return weapon
end

function Weapon:updateOrientation(dirVec)
	if dirVec.x == 0 and dirVec.y == 0 then
		self.rotation = -math.pi * 0.5
	else
		self.rotation = math.atan2(dirVec.x, -dirVec.y) - math.pi * 0.5
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
-- Funções de Renderização
----------------------------------------
function Weapon:draw(camera, owner)
	local wViewPos = camera:viewPos(owner.pos)

	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local flipY = (self.rotation / math.pi < -0.5 and self.rotation / math.pi >= -1.5) and -1 or 1 -- inverte arma no segundo e terceiro quadrantes

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(
		self.spriteSheets[self.state],
		quad,
		wViewPos.x,
		wViewPos.y,
		self.rotation,
		3,
		3 * flipY,
		animation.frameDim.width / 2 - 5,
		animation.frameDim.height / 2 - 5
	)
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
	local color = { r = 0.9, g = 0.9, b = 0.9, a = 1.0 }
	local katana = Weapon.new(KATANA, 30, math.huge, 1, 0, 120, Weapon.meleeAtack, color)
	local idlePath = "assets/sprites/weapons/katana/katana.png"
	local quadSize = { width = 64, height = 64 }
	local idleAnimation = newAnimation(idlePath, 1, quadSize, 1, true, 1, quadSize)
	katana.animations[IDLE] = idleAnimation
	katana.spriteSheets[IDLE] = love.graphics.newImage(idlePath)
	katana.spriteSheets[IDLE]:setFilter("nearest", "nearest")
	return katana
end

function newSlingShot()
	local color = { r = 0.7, g = 0.7, b = 0.4, a = 1.0 }
	local slingshot = Weapon.new(SLING_SHOT, 20, 5, 1.6, 1, 380, Weapon.slowProjectileAttack, color)
	local idlePath = "assets/sprites/weapons/slingshot/slingshot.png"
	local quadSize = { width = 64, height = 64 }
	local idleAnimation = newAnimation(idlePath, 1, quadSize, 1, true, 1, quadSize)
	slingshot.animations[IDLE] = idleAnimation
	slingshot.spriteSheets[IDLE] = love.graphics.newImage(idlePath)
	slingshot.spriteSheets[IDLE]:setFilter("nearest", "nearest")
	return slingshot
end
