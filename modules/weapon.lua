----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules/attacks")
require("modules/shapes")

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

function Weapon:new(name, ammo, cooldown, attack)
	local weapon = setmetatable({}, Weapon)

	-- atributos que variam
	weapon.name = name -- nome do tipo de arma
	weapon.ammo = ammo -- número de munições
	weapon.cooldown = cooldown -- tempo de espera entre ataques consecutivos
	weapon.atk = attack -- instância de Attack associada à arma
	-- atributos fixos na instanciação
	weapon.canShoot = false
	weapon.timer = 0 -- timer do cooldown
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

function Weapon:addAnimations()
	-- animação idle
	self:addAnimation(IDLE, 1, 1, true, 1)
end

function Weapon:addAnimation(action, numFrames, frameDur, looping, loopFrame)
	local folderName = string.lower(self.name:gsub(" ", ""))
	local path = "assets/animations/weapons/" .. folderName .. "/" .. action:gsub(" ", "_") .. ".png"
	local quadSize = { width = 64, height = 64 }
	local animation = newAnimation(path, numFrames, quadSize, frameDur, looping, loopFrame, quadSize)
	self.animations[action] = animation
	self.spriteSheets[action] = love.graphics.newImage(path)
	self.spriteSheets[action]:setFilter("nearest", "nearest")
end

function Weapon:update(dt)
	-- atualizando o cooldown
	if self.canShoot == false then
		self.timer = self.timer - dt
	end
	if self.timer < 0 then
		self.timer = self.cooldown
		self.canShoot = true
	end
	-- atualizando todos os ataques/eventos desferidos
	self.atk:update(dt)
end

----------------------------------------
-- Funções de Renderização
----------------------------------------
function Weapon:draw(camera)
	-- Não renderiza armas de jogadores se defendendo
	if self.owner.state == DEFENDING then
		return
	end

	local wViewPos = camera:viewPos(self.owner.pos)

	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	-- inverte arma no segundo e terceiro quadrantes
	local flipY = (self.rotation / math.pi < -0.5 and self.rotation / math.pi >= -1.5) and -1 or 1

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
	local updateFunc = function(dt, atkEvent)
		atkEvent:baseUpdate(dt)
	end
	local onHitFunc = function(atkEvent, target)
		print("Katana acertou um " .. target.type .. " por " .. atkEvent.dmg .. " de dano!")
		target.hp = target.hp - atkEvent.dmg
	end
	local atkSettings = newBaseAtkSetting(true, 15, 0.5, Circle:new(200))
	local atkAnimSettings = newAnimSetting(1, { width = 64, height = 64 }, 0.1, false, 1)
	local attack = Attack:new("Katana Slice", atkSettings, atkAnimSettings, updateFunc, onHitFunc)
	local katana = Weapon:new(KATANA, math.huge, 0.2, attack)
	katana:addAnimations()
	return katana
end

function newSlingShot()
	local updateFunc = function(dt, atkEvent)
		atkEvent:baseUpdate(dt)
	end
	local onHitFunc = function(atkEvent, target)
		print("Estilingue acertou um " .. target.type .. " por " .. atkEvent.dmg .. " de dano!")
		target.hp = target.hp - atkEvent.dmg
	end
	local baseAtkSettings = newBaseAtkSetting(true, 15, 1.5, Circle:new(200))
	local atkSettings = newProjectileAtkSetting(baseAtkSettings, 1, 1, 0, 2)
	local atkAnimSettings = newAnimSetting(5, { width = 16, height = 16 }, 0.1, true, 1)
	local attack = Attack:new("Pebble Shot", atkSettings, atkAnimSettings, updateFunc, onHitFunc)
	local slingshot = Weapon:new(SLING_SHOT, math.huge, 0.4, attack)
	slingshot:addAnimations()
	return slingshot
end
