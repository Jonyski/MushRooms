----------------------------------------
-- Classe PhysicsSettings
----------------------------------------

---@class PhysicsSettings
---@field mass number
---@field speed number
---@field friction number
---@field initialVel Vec
---@field initialAcc Vec
---@field speedRange range

---@param mass? number
---@param speed? number
---@param friction? number
---@param speedRange? range
---@param initialVel? Vec
---@param initialAcc? Vec
---@return PhysicsSettings
-- cria uma configuração de propriedades físicas para o
-- movimento e interação dinâmica entre entidades
function physicsSettings(mass, speed, friction, speedRange, initialVel, initialAcc)
	return {
		mass = mass or 1,
		speed = speed or 0,
		friction = friction or 1,
		speedRange = speedRange or range(0, math.huge),
		initialVel = initialVel or vec(0, 0),
		initialAcc = initialAcc or vec(0, 0),
	}
end

----------------------------------------
-- Classe Entity
----------------------------------------

---@class Entity
---@field name string
---@field pos? Vec
---@field hb? Hitbox
---@field room? Room
---@field mass number
---@field speed number
---@field friction number
---@field vel Vec
---@field acc Vec
---@field speedRange range
Entity = {}
Entity.__index = Entity

---@param name string
---@param pos? Vec
---@param hitbox? Hitbox
---@param room? Room
---@param entityPhysics? PhysicsSettings
-- inicializa uma entidade com propriedades básicas.
function Entity:init(name, pos, hitbox, room, entityPhysics)
	self.name = name or ""
	self.pos = pos
	self.hb = hitbox
	self.room = room

	local physics = entityPhysics and entityPhysics or physicsSettings()

	self.mass = physics.mass
	self.speed = physics.speed
	self.friction = physics.friction
	self.vel = physics.initialVel
	self.acc = physics.initialAcc
	self.speedRange = physics.speedRange

	self.invulnerableTimer = 0 -- timer de invulnerabilidade após levar dano
	self.blinkTimer = 0 -- timer para piscar o sprite do player quando invulnerável
end

function Entity:updateInvulnerability(dt)
	if self.invulnerableTimer > 0 then
		self.invulnerableTimer = self.invulnerableTimer - dt
		self.blinkTimer = (self.blinkTimer + dt * 10) % 1
	end
end

function Entity:isInvulnerable()
	local blink = 0.5
	return self.invulnerableTimer > 0 and self.blinkTimer < blink
end
