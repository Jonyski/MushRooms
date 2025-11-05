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

function Weapon.new(type, damage, ammo, cadence, cooldown, attack)
	local weapon = setmetatable({}, Weapon)

	-- atributos que variam
	weapon.type = type      -- nome do tipo de arma
	weapon.damage = damage  -- dano
	weapon.ammo = ammo      -- número de munições
	weapon.cadence = cadence -- número máximo de ataques por segundo
	weapon.cooldown = cooldown -- tempo de recarga
	weapon.attack = attack  -- método de ataque
	-- atributos fixos na instanciação
	weapon.target = nil     -- inimigo para o qual a arma está mirando
	weapon.rotation = 0     -- rotação da arma em radianos
	weapon.state = IDLE     -- estado atual da arma
	weapon.spriteSheets = {} -- no tipo imagem do love
	weapon.animations = {}  -- as chaves são estados e os valores são Animações

	return weapon
end

function Weapon:updateOrientation(dirVec)
	if dirVec.x == 0 and dirVec.y == 0 then
		self.rotation = -math.pi * 0.5
	else
		self.rotation = math.atan2(dirVec.x, -dirVec.y) - math.pi * 0.5
	end
end

function Weapon:addAnimations()
	-- animação idle
	self:addAnimation(IDLE, 1, 1, true, 1)
end

function Weapon:addAnimation(action, numFrames, frameDur, looping, loopFrame)
	local folderName = string.lower(self.type:gsub(" ", ""))
	local path = "assets/animations/weapons/" .. folderName .. "/" .. action:gsub(" ", "_") .. ".png"
	local quadSize = { width = 64, height = 64 }
	local animation = newAnimation(path, numFrames, quadSize, frameDur, looping, loopFrame, quadSize)
	self.animations[action] = animation
	self.spriteSheets[action] = love.graphics.newImage(path)
	self.spriteSheets[action]:setFilter("nearest", "nearest")
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
	-- Não renderiza armas de jogadores se defendendo
	if owner.state == DEFENDING then
		return
	end

	local wViewPos = camera:viewPos(owner.pos)

	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local flipY = (self.rotation / math.pi < -0.5 and self.rotation / math.pi >= -1.5) and -1 or
	1                                                                                           -- inverte arma no segundo e terceiro quadrantes

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
	local katana = Weapon.new(KATANA, 15, math.huge, 1, 0, Weapon.meleeAtack)
	katana:addAnimations()
	return katana
end

function newSlingShot()
	local slingshot = Weapon.new(SLING_SHOT, 8, 5, 1.6, 1, Weapon.slowProjectileAttack)
	slingshot:addAnimations()
	return slingshot
end
