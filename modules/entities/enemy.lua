require("modules.utils.types")
require("modules.utils.states")
require("modules.engine.collision")
require("table")

----------------------------------------
-- Variáveis
----------------------------------------
enemies = {}

----------------------------------------
-- Classe Enemy
----------------------------------------
Enemy = {}
Enemy.__index = Enemy
Enemy.type = ENEMY

function Enemy.new(name, hp, spawnPos, velocity, move, attack, hitbox)
	local enemy = setmetatable({}, Enemy)

	-- atributos que variam
	enemy.name = name -- nome do tipo de inimigo
	enemy.hp = hp -- pontos de vida do inimigo
	enemy.pos = spawnPos -- posição do inimigo
	enemy.vel = velocity -- velocidade de movimento do inimigo
	enemy.move = move -- função de movimento do inimigo
	enemy.attack = attack -- função de ataque do inimigo
	enemy.hb = hitbox -- hitbox do inimigo
	-- atributos fixos na instanciação
	enemy.size = { height = 32, width = 32 }
	enemy.cooldown = 0
	enemy.movementDirections = {} -- tabela com as direções de movimento atualmente ativas
	enemy.state = IDLE -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {} -- no tipo imagem do love
	enemy.animations = {} -- as chaves são estados e os valores são Animações

	return enemy
end

function Enemy:addAnimations(idleSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "enemies", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	---------------- DYING -----------------
--	local path = pngPathFormat({ "assets", "animations", "enemies", self.name, DYING })
--	addAnimation(self, path, DYING, dyingSettings)

	-- TODO: adicionar o resto das animações
end

function Enemy:takeDamage(damage)
	if self.state == DYING then
		return
	end

	self.hp = self.hp - damage
	if this.hp <= 0 then
		self:die()
	end

	---- debug ----
	print(self.hp)
end

function Enemy:die()
	self.state = DYING
	local anim = self.animations[DYING]
	anim.onFinish = function()
		collisionManager.enemies[self] = nil
		-- TODO: descobrir a sala para saber de onde remover a tabela
		table.remove(room.enemies, tableIndexOf(room.enemies, self))
	end
end


function Enemy:update(dt)
	self:move(dt)
	self:attack(dt)
	self.animations[self.state]:update(dt)
end

function Enemy:setPos(pos)
	self.pos = pos
	self.hb.pos = pos
end

----------------------------------------
-- Funções de Movimento
----------------------------------------
function Enemy:moveFollowPlayer(dt)
	local dx = players[1].pos.x - self.pos.x
	local dy = players[1].pos.y - self.pos.y
	local distance = math.sqrt(dx * dx + dy * dy)

	if distance > 100 then
		dx = dx / distance
		dy = dy / distance
		local newPos = vec(self.pos.x + dx * self.vel * dt, self.pos.y + dy * self.vel * dt)
		self:setPos(newPos)
	end
end

----------------------------------------
-- Funções de Ataque
----------------------------------------
function Enemy:simpleAttack(dt)
	if self.cooldown <= 0 then
		if math.abs(self.pos.x - players[1].pos.x) < 75 and math.abs(self.pos.y - players[1].pos.y) < 75 then
			print(self.name .. " ataca")
			self.cooldown = 3
			return
		end
	end
	self.cooldown = self.cooldown - dt
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

	---------- HITBOX DEBUG ----------
	if self.hb.shape.shape == CIRCLE then
		love.graphics.circle("line", viewPos.x, viewPos.y, self.hb.shape.radius)
	elseif self.hb.shape.shape == RECTANGLE then
		love.graphics.rectangle(
			"line",
			viewPos.x - self.hb.shape.halfW,
			viewPos.y - self.hb.shape.halfH,
			self.hb.shape.width,
			self.hb.shape.height
		)
	end
	----------------------------------
end

----------------------------------------
-- Construtores
----------------------------------------
function newEnemy(enemy, spawnPos)
	if enemy == NUCLEAR_CAT then
		newNuclearCat(spawnPos)
	elseif enemy == SPIDER_DUCK then
		newSpiderDuck(spawnPos)
	end
end

function newNuclearCat(spawnPos)
	local movementFunc = Enemy.moveFollowPlayer
	local attackFunc = Enemy.simpleAttack
	local hitbox = hitbox(Rectangle.new(40, 70), spawnPos)
	local enemy = Enemy.new(NUCLEAR_CAT.name, 30, spawnPos, 180, movementFunc, attackFunc, hitbox)
	local idleAnimSettings = newAnimSetting(6, { width = 32, height = 32 }, 0.15, true, 1)
	enemy:addAnimations(idleAnimSettings)
	table.insert(enemies, enemy)
	return enemy
end

function newSpiderDuck(spawnPos)
	local movementFunc = Enemy.moveFollowPlayer
	local attackFunc = Enemy.simpleAttack
	local hitbox = hitbox(Circle.new(25), spawnPos)
	local enemy = Enemy.new(SPIDER_DUCK.name, 20, spawnPos, 180, movementFunc, attackFunc, hitbox)
	local idleAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.4, true, 1)
	enemy:addAnimations(idleAnimSettings)
	table.insert(enemies, enemy)
	return enemy
end
