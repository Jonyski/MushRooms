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
---@field attack Attack
---@field hb Hitbox
---@field room Room
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field target any
---@field atk Attack
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
	enemy.atk = attack -- objeto Attack associado ao inimigo (caso possua)
	enemy.hb = hitbox -- hitbox do inimigo
	enemy.room = room -- sala do inimigo
	-- atributos fixos na instanciação
	enemy.state = IDLE -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {} -- no tipo imagem do love
	enemy.animations = {} -- as chaves são estados e os valores são Animações
	enemy.target = nil -- alvo atual do inimigo

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

function Enemy:attack()
	-- as condições para tentar um ataque não são cumpridas
	if not self.target or not self.target.pos or not self.atk then
		return
	end
	local dir = math.atan2(self.target.pos.y - self.pos.y, self.target.pos.x - self.pos.x)
	self.atk:tryAttack(self, self.pos, dir)
end

---@param dt number
-- atualiza os estados do inimigo e seus ataques, além de movê-lo
function Enemy:update(dt)
	self:defineTarget()
	if self.move then
		self:move(dt)
	end
	if self.atk then
		self.atk:update(dt)
	end
	self:attack()
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
