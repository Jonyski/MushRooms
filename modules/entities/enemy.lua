----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.states")
require("modules.engine.collision")
require("modules.utils.easing")
require("table")

----------------------------------------
-- Classe Enemy
----------------------------------------
Enemy = {}
Enemy.__index = Enemy
Enemy.type = ENEMY

function Enemy.new(name, hp, spawnPos, speed, move, attack, hitbox, room)
	local enemy = setmetatable({}, Enemy)

	-- atributos que variam
	enemy.name = name  -- nome do tipo de inimigo
	enemy.hp = hp      -- pontos de vida do inimigo
	enemy.pos = spawnPos -- posição do inimigo
	enemy.speed = speed -- velocidade de movimento do inimigo
	enemy.move = move  -- função de movimento do inimigo
	enemy.attack = attack -- função de ataque do inimigo
	enemy.hb = hitbox  -- hitbox do inimigo
	enemy.room = room  -- sala do inimigo
	-- atributos fixos na instanciação
	enemy.size = { height = 32, width = 32 }
	enemy.cooldownTable = {}     -- tabela para cooldowns múltiplos, caso necessário
	enemy.movementDirections = {} -- tabela com as direções de movimento atualmente ativas
	enemy.state = IDLE           -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {}      -- no tipo imagem do love
	enemy.animations = {}        -- as chaves são estados e os valores são Animações
	enemy.target = nil           -- alvo atual do inimigo
	enemy.moveTargetPos = vec(0, 0) -- posição alvo para movimentação randômica
	enemy.moveOriginPos = vec(0, 0) -- posição inicial para movimentação com easing
	enemy.moveTimer = 0          -- timer para movimentação com easing
	enemy.moveDuration = 0       -- duração da movimentação com easing
	enemy.attackObj = nil        -- objeto Attack associado ao inimigo (caso possua)

	return enemy
end

function Enemy:addAnimations(idleSettings, dyingSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "enemies", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	---------------- DYING -----------------
	path = pngPathFormat({ "assets", "animations", "enemies", self.name, IDLE })
	addAnimation(self, path, DYING, dyingSettings)

	-- TODO: adicionar o resto das animações
end

function Enemy:takeDamage(damage)
	if self.state == DYING then
		return
	end

	self.hp = self.hp - damage
	if self.hp <= 0 then
		self:die()
	end
end

function Enemy:die()
	self.state = DYING
	local anim = self.animations[DYING]
	anim.onFinish = function()
		collisionManager.enemies[self] = nil
		table.remove(self.room.enemies, tableIndexOf(self.room.enemies, self))
	end
end

function Enemy:update(dt)
	self:reduceCooldowns(dt)
	self:defineTarget()
	self:move(dt)
	self:executeMovementDirections()

	if self.attackObj then
		self.attackObj:update(dt)
	end

	self:attack(dt)
	self.animations[self.state]:update(dt)
end

function Enemy:setPos(pos)
	self.pos = pos
	self.hb.pos = pos
end

----------------------------------------
-- Funções de Estado
----------------------------------------

function Enemy:defineTarget()
	self.target = self:getClosestPlayer()
end

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

function Enemy:reduceCooldowns(dt)
	for key, value in pairs(self.cooldownTable) do
		if value > 0 then
			self.cooldownTable[key] = value - dt
		end
	end
end

function Enemy:isCooldownActive(cooldownName)
	if self.cooldownTable[cooldownName] and self.cooldownTable[cooldownName] > 0 then
		return true
	end
	return false
end

function Enemy:setCooldown(cooldownName, value)
	self.cooldownTable[cooldownName] = value
end

----------------------------------------
-- Funções de Movimento
----------------------------------------

-- se move na direção de um ponto específico
function Enemy:moveTowards(pos, dt)
	if self.easingFunc and self.moveOriginPos and self.moveDuration and self.moveTimer then
		self.moveTimer = self.moveTimer + dt
		local t = math.min(self.moveTimer / self.moveDuration, 1)
		local progress = self.easingFunc(t)
		local targetPos = addVec(self.moveOriginPos, scaleVec(subVec(pos, self.moveOriginPos), progress))
		local movementVec = subVec(targetPos, self.pos)

		self.movementDirections["moveTowards"] = movementVec

		return
	end

	-- movimento normal (sem easing)
	local direction = normalize(subVec(pos, self.pos))
	self.movementDirections["moveTowards"] = scaleVec(direction, self.speed * dt)
end

-- se move na direção contrário do target
function Enemy:avoidTarget(dt)
	if self.target == nil or self:isCooldownActive("avoidTarget") then
		return
	end

	local distTarget = dist(self.pos, self.target.pos)

	if nullVec(self.moveTargetPos) and distTarget < 300 then
		local baseDir = normalize(subVec(self.target.pos, self.pos))
		baseDir = scaleVec(baseDir, -1)
		local travelDistance = math.random(150, 180)

		self.moveTargetPos = addVec(self.pos, scaleVec(baseDir, travelDistance))
		self.moveOriginPos = self.pos
		self.moveTimer = 0
		self.moveDuration = travelDistance / self.speed
	end

	local arrived = false
	if self.easingFunc then
		if self.moveTimer >= self.moveDuration then
			arrived = true
		end
	elseif nullVec(self.moveTargetPos) or dist(self.pos, self.moveTargetPos) <= 4 then
		arrived = true
	end

	if not arrived then
		self:moveTowards(self.moveTargetPos, dt)
	else
		self.movementDirections["moveTowards"] = vec(0, 0)
		self.moveTargetPos = vec(0, 0)
		self:setCooldown("avoidTarget", 1.0 + math.random() / 2)
	end
end

-- se move na direção de um target
function Enemy:moveFollowTarget(dt)
	if self.target == nil then
		return
	end

	local distance = dist(self.pos, self.target.pos)

	if distance > 100 then
		self:moveTowards(self.target.pos, dt)
	end
end

function Enemy:moveTargetDirection(dt)
	if self.target == nil or self:isCooldownActive("moveTargetDirection") then
		return
	end

	if nullVec(self.moveTargetPos) then
		local baseDir = normalize(subVec(self.target.pos, self.pos))
		local randAngle = math.rad(45) * (math.random() - 0.5) * 2

		local newDir = rotateVec(baseDir, randAngle)
		local travelDistance = math.random(110, 200)

		self.moveTargetPos = addVec(self.pos, scaleVec(newDir, travelDistance))
		self.moveOriginPos = self.pos
		self.moveTimer = 0
		self.moveDuration = travelDistance / self.speed
	end

	local arrived = false
	if self.easingFunc then
		if self.moveTimer >= self.moveDuration then
			arrived = true
		end
	elseif dist(self.pos, self.moveTargetPos) <= 4 then
		arrived = true
	end

	if not arrived then
		self:moveTowards(self.moveTargetPos, dt)
	else
		self.movementDirections["moveTowards"] = vec(0, 0)
		self.moveTargetPos = vec(0, 0)
		self:setCooldown("moveTargetDirection", 0.3 + math.random())
	end
end

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

function Enemy:shootAttack(dt)
	if self.target == nil or self:isCooldownActive("shootAttack") then
		return
	end

	self:setCooldown("shootAttack", 2)

	local dir = math.atan2(self.target.pos.y - self.pos.y, self.target.pos.x - self.pos.x)
	self.attackObj:attack(self, self.pos, dir)
end

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
