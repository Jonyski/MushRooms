----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.states")
require("modules.engine.collision")
require("table")

----------------------------------------
-- Classe Enemy
----------------------------------------

---@class Enemy
---@field name string
---@field hp number
---@field pos Vec
---@field speed number
---@field move function
---@field attack Attack | function
---@field hb Hitbox
---@field room Room
---@field cooldownTable table<string, number>
---@field movementDirections Vec[]
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field target any
---@field attackObj Attack
---@field addAnimations function
---@field setProjectileAtk function

Enemy = {}
Enemy.__index = Enemy
Enemy.type = ENEMY

---@param name string
---@param hp number
---@param spawnPos Vec
---@param speed number
---@param move function
---@param attack Attack | function
---@param hitbox Hitbox
---@param room Room
---@return Enemy
-- cria uma instância de `Enemy`
function Enemy.new(name, hp, spawnPos, speed, move, attack, hitbox, room)
	local enemy = setmetatable({}, Enemy)

	-- atributos que variam
	enemy.name = name -- nome do tipo de inimigo
	enemy.hp = hp -- pontos de vida do inimigo
	enemy.pos = spawnPos -- posição do inimigo
	enemy.speed = speed -- velocidade de movimento do inimigo
	enemy.move = move -- função de movimento do inimigo
	enemy.attack = attack -- função de ataque do inimigo
	enemy.hb = hitbox -- hitbox do inimigo
	enemy.room = room -- sala do inimigo
	-- atributos fixos na instanciação
	enemy.cooldownTable = {} -- tabela para cooldowns múltiplos, caso necessário
	enemy.movementDirections = {} -- tabela com as direções de movimento atualmente ativas
	enemy.state = IDLE -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {} -- no tipo imagem do love
	enemy.animations = {} -- as chaves são estados e os valores são Animações
	enemy.target = nil -- alvo atual do inimigo
	enemy.attackObj = nil -- objeto Attack associado ao inimigo (caso possua)

	return enemy
end

---@param idleSettings AnimSettings
---@param dyingSettings AnimSettings
-- adiciona as animações dos estados dos inimigos à sua tabela de animações
function Enemy:addAnimations(idleSettings, dyingSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "enemies", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	---------------- DYING -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, IDLE })
	addAnimation(self, path, DYING, dyingSettings)

	-- TODO: adicionar o resto das animações
end

---@param damage number
-- reduz a vida do `Enemy` em `damage` pontos. Caso a vida
-- chegue abaixo de 0, mata o inimigo
function Enemy:takeDamage(damage)
	if self.state == DYING then
		return
	end

	self.hp = self.hp - damage
	if self.hp <= 0 then
		self:die()
	end
end

-- inicia o processo de morte do inimigo
function Enemy:die()
	self.state = DYING
	local anim = self.animations[DYING]
	anim.onFinish = function()
		collisionManager.enemies[self] = nil
		table.remove(self.room.enemies, tableIndexOf(self.room.enemies, self))
	end
end

---@param dt number
-- atualiza os estados do inimigo e seus ataques, além de movê-lo
function Enemy:update(dt)
	self:reduceCooldowns(dt)
	self:defineTarget()
	if self.move then
		self:move(dt)
	end
	if self.attackObj then
		self.attackObj:update(dt)
	end
	self:attack(dt)
	self.animations[self.state]:update(dt)
end

----------------------------------------
-- Funções de Estado
----------------------------------------

-- define o alvo atual do `Enemy`
function Enemy:defineTarget()
	self.target = self:getClosestPlayer()
end

---@return any
-- encontra o jogador mais próximo ao `Enemy`
function Enemy:getClosestPlayer()
	local closestDist = math.huge
	local closestPlayer = nil

	for _, p in pairs(players) do
		if dist(self.pos, p.pos) < closestDist then
			closestDist = dist(self.pos, p.pos)
			closestPlayer = p
		end
	end

	return closestPlayer
end

---@param dt number
-- reduz os cooldowns dos ataques do `Enemy`
function Enemy:reduceCooldowns(dt)
	for key, value in pairs(self.cooldownTable) do
		if value > 0 then
			self.cooldownTable[key] = value - dt
		end
	end
end

---@param cooldownName string
---@return boolean
-- checa se o cooldown com nome `cooldownName` está ativo ou já chegou a 0
function Enemy:isCooldownActive(cooldownName)
	if self.cooldownTable[cooldownName] and self.cooldownTable[cooldownName] > 0 then
		return true
	end
	return false
end

---@param cooldownName string
---@param value number
-- cria ou atualiza um cooldown com nome `cooldownName` para ter o valor `value`
function Enemy:setCooldown(cooldownName, value)
	self.cooldownTable[cooldownName] = value
end

----------------------------------------
-- Funções de Movimento
----------------------------------------

-- soma todos os vetores de direção de movimento e atualiza a posição do inimigo
function Enemy:executeMovementDirections()
	local finalDir = vec(0, 0)

	for _, v in pairs(self.movementDirections) do
		finalDir = addVec(finalDir, v)
	end

	self:setPos(addVec(self.pos, finalDir))
end

----------------------------------------
-- Funções de Ataque
----------------------------------------

---@param dt? number
-- ataque que ainda não faz nada
function Enemy:simpleAttack(dt)
	if self:isCooldownActive("simpleAttack") then
		return
	end

	if math.abs(dist(self.pos, self.target.pos)) < 75 then
		print(self.name .. " ataca")
		self:setCooldown("simpleAttack", 2)

		return
	end
end

---@param dt? number
-- ataque de projétil
function Enemy:shootAttack(dt)
	if self.target == nil or self:isCooldownActive("shootAttack") then
		return
	end

	self:setCooldown("shootAttack", 2)

	local dir = math.atan2(self.target.pos.y - self.pos.y, self.target.pos.x - self.pos.x)
	self.attackObj:attack(self, self.pos, dir)
end

-- define o ataque de `Enemy` como sendo um ataque de projétil
-- com trajetória senoidal
function Enemy:setProjectileAtk()
	local updateFunc = function(dt, atkEvent)
		atkEvent:baseUpdate(dt)
	end

	local onHitFunc = function(atkEvent, target)
		-- TODO: colocar partículas bonitinhas ao acertar

		print(atkEvent.attacker.name .. " acertou um " .. target.type .. " por " .. atkEvent.dmg .. " de dano!")
		target.hp = target.hp - atkEvent.dmg
	end

	local hb = hitbox(Circle.new(15), vec(0, 0))
	local baseAtkSettings = newBaseAtkSetting(true, 15, 5, hb)
	local atkSettings = newProjectileAtkSetting(baseAtkSettings, 10, 5, 0, 1)
	local atkAnimSettings = newAnimSetting(5, { width = 16, height = 16 }, 0.1, true, 1)
	local trajectoryFunc = SineTrajectory

	self.attackObj = Attack.new("Pebble Shot", atkSettings, atkAnimSettings, updateFunc, onHitFunc, trajectoryFunc)
end

----------------------------------------
-- Funções de Renderização
----------------------------------------

---@param camera Camera
-- função de renderização de `Enemy`
function Enemy:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local offset = {
		x = animation.frameDim.width / 2,
		y = animation.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
end
