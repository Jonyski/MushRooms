require "./modules/player"
require "table"
----------------------------------------
-- Variáveis
----------------------------------------
NUCLEAR_CAT = 1
SPIDER_DUCK = 2

enemies = {}

----------------------------------------
-- Classe Enemy
----------------------------------------
Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name, spawnPos, velocity, color, move, attack)
	local enemy = setmetatable({}, Enemy)
	
	-- atributos que variam
	enemy.name = name     -- nome do inimigo
	enemy.pos = spawnPos  -- posição do inimigo
	enemy.vel = velocity  -- velocidade de movimento do inimigo
	enemy.color = color   -- cor do inimigo
	enemy.move = move     -- função de movimento do inimigo
	enemy.attack = attack -- função de ataque do inimigo
	-- atributos fixos na instanciação
	enemy.size = {height = 32, width = 32}
	enemy.cooldown = 0
	enemy.movementDirections = {} -- tabela com as direções de movimento atualmente ativas
	enemy.state = IDLE            -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {}       -- no tipo imagem do love
	enemy.animations = {}         -- as chaves são estados e os valores são Animações

	return enemy
end

----------------------------------------
-- Funções e Enums de Movimento
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
-- Funções e Enums de Ataque
----------------------------------------
function Enemy:simpleAttack(dt)
	if self.cooldown <= 0 then
		if math.abs(self.pos.x - players[1].pos.x) < 75 and
	   	   math.abs(self.pos.y - players[1].pos.y) < 75 then
	   		print("Gatinho ataca")
	   		self.cooldown = 3
	   		return
		end
	end
	self.cooldown = self.cooldown - dt
end

----------------------------------------
-- Funções Globais
----------------------------------------
function newEnemy(name, spawnPos)
	if name == NUCLEAR_CAT then
		newNuclearCat(spawnPos)
	elseif name == SPIDER_DUCK then
		newSpiderDuck(spawnPos)
	end
end

function newNuclearCat(spawnPos)
	local color = {r = 0.9, g = 0.4, b = 0.4, a = 1.0}
	local movementFunc = Enemy.moveFollowPlayer
	local attackFunc = Enemy.simpleAttack
	local enemy = Enemy.new("Nuclear Cat", spawnPos, 180, color, movementFunc, attackFunc)
	table.insert(enemies, enemy)
end

function newSpiderDuck(spawnPos)
	local color = {r = 0.9, g = 0.9, b = 0.1, a = 1.0}
	local movementFunc = Enemy.moveFollowPlayer
	local attackFunc = Enemy.simpleAttack
	local enemy = Enemy.new("Spider Duck", spawnPos, 180, color, movementFunc, attackFunc)
	table.insert(enemies, enemy)
end