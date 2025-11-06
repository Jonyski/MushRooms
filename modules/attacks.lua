----------------------------------------
-- Funções auxiliares para Ataques
----------------------------------------

function newBaseAtkSetting(ally, damage, duration, hitboxShape)
	return {
		ally = ally,
		damage = damage,
		duration = duration,
		hitbox = hitboxShape,
		-- por padrão, ataques não terão velocidade, aceleração, quiques e atravessam infinitos alvos (Melee)
		speed = 0,
		acceleration = 0,
		bounces = 0,
		pierces = math.huge,
	}
end

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

-- Attack States guardam apenas dados iniciais sobre ataques, e não comportamentos
function Attack:new(name, atkSettings, animSettings, updateFunc, onHit)
	local attack = setmetatable({}, Attack)
	attack.name = name -- nome do tipo de ataque
	attack.ally = atkSettings.ally -- true se for de um player e false se for de um inimigo
	attack.dmg = atkSettings.damage -- dano base do ataque
	attack.dur = atkSettings.duration -- duração do evento de ataque associado
	attack.speed = atkSettings.speed -- fator inicial de velocidade do ataque/projétil
	attack.acc = atkSettings.acc -- fator inicial de aceleração do ataque/projétil
	attack.hb = atkSettings.hitbox -- formato do ataque (para detecção de colisões)
	attack.bounces = atkSettings.bounces -- quantas vezes o ataque pode ricochetear (caso seja projétil)
	attack.pierces = atkSettings.pierces -- quantas vezes o ataque pode atravessar um alvo
	attack.animSettings = animSettings -- configurações da animação de cada evento
	attack.updateEvent = updateFunc -- função executada para cada AttackEvent, atualizando seu estado atual
	attack.onHit = onHit -- função executada toda vez que um ataque acertar um alvo
	-- Atributos fixos na instanciação
	attack.events = {}
	return attack
end

function Attack:attack(origin, direction)
	local atkEvent = AttackEvent:new(self, origin, direction)
	atkEvent:addAnimation(self.animSettings)
	table.insert(self.events, atkEvent)
end

function Attack:update(dt)
	for i = #self.events, 1, -1 do
		local e = self.events[i]
		self.updateEvent(dt, e)

		if e.timer <= 0 then
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

-- Attack Events armazenam o comportamento de um ataque
-- são instanciados a cada ataque e destruídos ao fim do timer
function AttackEvent:new(attackState, origin, direction)
	local atkEvent = setmetatable({}, AttackEvent)
	atkEvent.name = attackState.name -- para descobrirmos o caminho até os assets
	atkEvent.pos = origin -- posição atual do ataque
	atkEvent.dmg = attackState.dmg -- dano atual do ataque (caso mude com o tempo)
	atkEvent.timer = attackState.dur -- tempo até o ataque terminar
	atkEvent.speed = attackState.speed -- coeficiente de velocidade do ataque/projétil
	atkEvent.vel = scaleVec(direction, attackState.speed) -- vetor de velocidade atual do ataque
	atkEvent.acc = scaleVec(direction, attackState.acc) -- aceleração atual do ataque
	atkEvent.hb = attackState.hb -- formato da hitbox
	atkEvent.bouncesLeft = attackState.bounces -- número de ricochetes restantes
	atkEvent.piercesLeft = attackState.pierces -- número de alvos atravessáveis restantes
	-- Atributos fixos na instanciação
	atkEvent.active = true -- se o ataque atualmente pode dar dano
	atkEvent.targetsDamaged = {} -- lista de alvos feridos pelo ataque
	return atkEvent
end

function AttackEvent:baseUpdate(dt)
	self.vel = addVec(self.vel, self.acc)
	self.pos = addVec(self.pos, self.vel)
	self.timer = self.timer - dt
	-- print(self.timer)
end

----------------------------------------
-- Funções de AttackEvents
----------------------------------------

function AttackEvent:addAnimation(settings)
	local path = "assets/animations/attacks/" .. string.lower(self.name:gsub(" ", "_")) .. "/sheet.png"
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
	local wViewPos = camera:viewPos(self.pos)
	local animation = self.animation
	local quad = animation.frames[animation.currFrame]

	love.graphics.draw(
		self.spriteSheet,
		quad,
		wViewPos.x,
		wViewPos.y,
		0,
		3,
		3,
		animation.frameDim.width / 2,
		animation.frameDim.height / 2
	)
end
