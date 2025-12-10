----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.utils")

----------------------------------------
-- Funções auxiliares para Ataques
----------------------------------------
-- construtor de configuração base para ataques melee
function newBaseAtkSetting(ally, damage, duration, hitbox)
	return {
		ally = ally,
		damage = damage,
		duration = duration,
		hitbox = hitbox,
		-- por padrão, ataques não terão velocidade, aceleração, quiques e atravessam infinitos alvos (Melee)
		speed = 0,
		acc = 0,
		bounces = 0,
		pierces = math.huge,
	}
end

-- construtor complementar ao anterior, usado para ataques de projétil
function newProjectileAtkSetting(baseSettings, speed, acceleration, bounces, pierces)
	return {
		ally = baseSettings.ally,
		damage = baseSettings.damage,
		duration = baseSettings.duration,
		hitbox = baseSettings.hitbox,
		speed = speed,
		acc = acceleration,
		bounces = bounces,
		pierces = pierces,
	}
end

----------------------------------------
-- Classe AttackState
----------------------------------------

Attack = {}
Attack.__index = Attack
Attack.type = ATTACK

-- Attack States guardam apenas dados iniciais sobre ataques, e não comportamentos
function Attack.new(name, atkSettings, animSettings, updateFunc, onHit, trajectoryFunc)
	local attack = setmetatable({}, Attack)
	attack.name = name                  -- nome do tipo de ataque
	attack.ally = atkSettings.ally      -- true se for de um player e false se for de um inimigo
	attack.dmg = atkSettings.damage     -- dano base do ataque
	attack.dur = atkSettings.duration   -- duração do evento de ataque associado
	attack.speed = atkSettings.speed    -- fator inicial de velocidade do ataque/projétil
	attack.acc = atkSettings.acc        -- fator inicial de aceleração do ataque/projétil
	attack.hb = atkSettings.hitbox      -- hitbox do ataque
	attack.bounces = atkSettings.bounces -- quantas vezes o ataque pode ricochetear (caso seja projétil)
	attack.pierces = atkSettings.pierces -- quantas vezes o ataque pode atravessar um alvo
	attack.animSettings = animSettings  -- configurações da animação de cada evento
	attack.updateEvent = updateFunc     -- função executada para cada AttackEvent, atualizando seu estado atual
	attack.onHit = onHit                -- função executada toda vez que um ataque acertar um alvo
	attack.trajectoryFunc = trajectoryFunc -- função que define a trajetória do ataque/projétil
	-- Atributos fixos na instanciação
	attack.events = {}
	return attack
end

function Attack:attack(attacker, origin, direction)
	local atkEvent = AttackEvent.new(self, attacker, origin, direction)
	atkEvent:addAnimation(self.animSettings)
	table.insert(self.events, atkEvent)
end

function Attack:update(dt)
	for i = #self.events, 1, -1 do
		local e = self.events[i]
		self.updateEvent(dt, e)

		if e.timer <= 0 or e.piercesLeft <= 0 then
			e.active = false
			table.remove(self.events, i)
		else
			e.animation:update(dt)
		end
	end
end

----------------------------------------
-- Classe AttackEvent
----------------------------------------

AttackEvent = {}
AttackEvent.__index = AttackEvent
AttackEvent.type = ATTACK_EVENT

-- Attack Events armazenam o comportamento de um ataque
-- são instanciados a cada ataque e destruídos ao fim do timer
function AttackEvent.new(attackState, attacker, origin, direction)
	local atkEvent = setmetatable({}, AttackEvent)
	local dirVec = polarToVec(direction, 1)
	atkEvent.name = attackState.name                  -- para descobrirmos o caminho até os assets
	atkEvent.attacker = attacker                      -- jogador ou inimigo que desferiu o ataque
	atkEvent.pos = origin                             -- posição atual do ataque
	atkEvent.dmg = attackState.dmg                    -- dano atual do ataque (caso mude com o tempo)
	atkEvent.timer = attackState.dur                  -- tempo até o ataque terminar
	atkEvent.speed = attackState.speed                -- coeficiente de velocidade do ataque/projétil
	atkEvent.dur = attackState.dur                    -- duração total do ataque/projétil
	atkEvent.direction = direction                    -- ângulo do ataque em radianos
	atkEvent.vel = scaleVec(dirVec, attackState.speed) -- vetor de velocidade atual do ataque
	atkEvent.acc = scaleVec(dirVec, attackState.acc)  -- aceleração atual do ataque
	atkEvent.hb = copyHitbox(attackState.hb, origin)  -- formato da hitbox
	atkEvent.bouncesLeft = attackState.bounces        -- número de ricochetes restantes
	atkEvent.piercesLeft = attackState.pierces        -- número de alvos atravessáveis restantes
	atkEvent.trajectoryFunc = attackState.trajectoryFunc -- função que define a trajetória do ataque/projétil
	atkEvent.onHitFunc = attackState.onHit            -- função executada ao acertar um alvo
	atkEvent.target = attacker.target                 -- alvo do ataque
	-- Atributos fixos na instanciação
	atkEvent.age = 0                                  -- tempo desde a criação do ataque
	atkEvent.active = true                            -- se o ataque atualmente pode dar dano
	atkEvent.targetsDamaged = {}                      -- lista de alvos feridos pelo ataque

	-- adicionando à respectiva lista de hitboxes
	if attacker.type == PLAYER then
		collisionManager.playerAttacks[atkEvent] = atkEvent.hb
	elseif attacker.type == ENEMY then
		collisionManager.enemyAttacks[atkEvent] = atkEvent.hb
	end

	return atkEvent
end

function AttackEvent:baseUpdate(dt)
	self.age = self.age + dt

	-- aplica função de trajetória se existir
	if self.trajectoryFunc then
		self.vel = self.trajectoryFunc(self, dt)
	end

	-- movimenta padrão
	local acc = scaleVec(self.acc, dt)
	self.vel = addVec(self.vel, acc)
	self.pos = addVec(self.pos, self.vel)
	self.hb.pos = self.pos
	self.timer = self.timer - dt
end

----------------------------------------
-- Funções de AttackEvents
----------------------------------------

function AttackEvent:addAnimation(settings)
	local path = pngPathFormat({ "assets", "animations", "attacks", self.name, "sheet" })
	local animation = newAnimation(
		path,
		settings.numFrames,
		settings.quadSize,
		settings.frameDur,
		settings.looping,
		settings.loopFrame,
		settings.quadSize
	)
	self.animation = animation
	self.spriteSheet = love.graphics.newImage(path)
	self.spriteSheet:setFilter("nearest", "nearest")
end

function AttackEvent:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local animation = self.animation
	local quad = animation.frames[animation.currFrame]
	local flipY = (self.direction / math.pi < -0.5 and self.direction / math.pi >= -1.5) and -1 or 1

	love.graphics.draw(
		self.spriteSheet,
		quad,
		viewPos.x,
		viewPos.y,
		self.direction,
		3,
		3 * flipY,
		animation.frameDim.width / 2,
		animation.frameDim.height / 2
	)
end

----------------------------------------
--- Funções de Trajetória
-----------------------------------------

function QuadraticTrajectory(self, dt)
	if not self.target then
		return self.vel
	end

	local dx = self.target.pos.x - self.pos.x
	local dy = self.target.pos.y - self.pos.y

	local newDir = self.vel
	local threshold = 80

	if math.abs(dx) > math.abs(dy) + threshold then
		newDir.x = dx
		newDir.y = 0
	elseif math.abs(dy) > math.abs(dx) + threshold then
		newDir.y = dy
		newDir.x = 0
	end

	newDir = normalize(newDir)
	return scaleVec(newDir, self.speed)
end

function HomingTrajectory(self, dt)
	if not self.target then
		return self.vel
	end

	local velDir = normalize(self.vel)
	local toTargetDir = normalize(subVec(self.target.pos, self.pos))

	local angleDiff = math.atan2(toTargetDir.y, toTargetDir.x) - math.atan2(velDir.y, velDir.x)

	angleDiff = (angleDiff + math.pi) % (2 * math.pi) - math.pi

	local turnSpeed = math.rad(120)
	local angle = angleDiff * turnSpeed * dt
	local newDir = rotateVec(velDir, angle)

	return scaleVec(newDir, self.speed)
end

function ZigZagTrajectory(self, dt)
	local ampDeg = math.rad(60)
	local angle = sign(math.sin(self.age * 10)) * ampDeg

	local newAngle = self.direction + angle
	local newDir = polarToVec(newAngle, 1)

	return scaleVec(newDir, self.speed)
end

function SineTrajectory(self, dt)
	local ampDeg = math.rad(60)
	local newAngle = self.direction + math.sin(self.age * 5) * ampDeg -- amplitude e frequência
	local newDir = polarToVec(newAngle, 1)

	return scaleVec(newDir, self.speed)
end
