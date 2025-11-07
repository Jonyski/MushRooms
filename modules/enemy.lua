require("modules/player")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------
NUCLEAR_CAT = "Nuclear Cat"
SPIDER_DUCK = "Spider Duck"

enemies = {}

----------------------------------------
-- Classe Enemy
----------------------------------------
Enemy = {}
Enemy.__index = Enemy

function Enemy.new(type, hp, spawnPos, velocity, color, move, attack)
	local enemy = setmetatable({}, Enemy)

	-- atributos que variam
	enemy.type = type -- nome do tipo de inimigo
	enemy.hp = hp -- pontos de vida do inimigo
	enemy.pos = spawnPos -- posição do inimigo
	enemy.vel = velocity -- velocidade de movimento do inimigo
	enemy.color = color -- cor do inimigo
	enemy.move = move -- função de movimento do inimigo
	enemy.attack = attack -- função de ataque do inimigo
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
	-- animação idle
	local path = pngPathFormat({ "assets", "animations", "enemies", self.type, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	-- TODO: adicionar o resto das animações
end

function Enemy:update(dt)
	self:move(dt)
	self:attack(dt)
	self.animations[self.state]:update(dt)
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

		self.pos.x = self.pos.x + dx * self.vel * dt
		self.pos.y = self.pos.y + dy * self.vel * dt
	end
end

----------------------------------------
-- Funções de Ataque
----------------------------------------
function Enemy:simpleAttack(dt)
	if self.cooldown <= 0 then
		if math.abs(self.pos.x - players[1].pos.x) < 75 and math.abs(self.pos.y - players[1].pos.y) < 75 then
			print(self.type .. " ataca")
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
end

----------------------------------------
-- Construtores
----------------------------------------
function newEnemy(type, spawnPos)
	if type == NUCLEAR_CAT then
		newNuclearCat(spawnPos)
	elseif type == SPIDER_DUCK then
		newSpiderDuck(spawnPos)
	end
end

function newNuclearCat(spawnPos)
	local color = { r = 0.9, g = 0.4, b = 0.4, a = 1.0 }
	local movementFunc = Enemy.moveFollowPlayer
	local attackFunc = Enemy.simpleAttack
	local enemy = Enemy.new(NUCLEAR_CAT, 30, spawnPos, 180, color, movementFunc, attackFunc)
	local idleAnimSettings = newAnimSetting(6, { width = 32, height = 32 }, 0.15, true, 1)
	enemy:addAnimations(idleAnimSettings)
	table.insert(enemies, enemy)
end

function newSpiderDuck(spawnPos)
	local color = { r = 0.9, g = 0.9, b = 0.1, a = 1.0 }
	local movementFunc = Enemy.moveFollowPlayer
	local attackFunc = Enemy.simpleAttack
	local enemy = Enemy.new(SPIDER_DUCK, 20, spawnPos, 180, color, movementFunc, attackFunc)
	local idleAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.4, true, 1)
	enemy:addAnimations(idleAnimSettings)
	table.insert(enemies, enemy)
end
