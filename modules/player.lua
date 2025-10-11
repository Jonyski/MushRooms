----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules/utils")
require("modules/animation")
require("modules/vec")
require("table")

----------------------------------------
-- Variáveis
----------------------------------------
players = {}

IDLE = "idle"
WALKING_UP = "walking up"
WALKING_DOWN = "walking down"
WALKING_LEFT = "walking left"
WALKING_RIGHT = "walking right"
DEFENDING = "defending"
ATTACKING = "attacking"

----------------------------------------
-- Classe Player
----------------------------------------
Player = {}
Player.__index = Player

-- Construtor
function Player.new(id, name, spawn_pos, controls, color, room)
	local player = setmetatable({}, Player)

	-- atributos que variam
	player.id = id                         -- número do jogador
	player.name = name                     -- nome do jogador
	player.pos = spawn_pos                 -- posição do jogador (inicializa para a posição do spawn)
	player.controls =
	controls                               -- os comandos para controlar o boneco, no formato {up = "", left = "", down = "", right = "", action = ""}
	player.color = color                   -- cor que representa o jogador
	player.room = room                     -- sala na qual o jogador está atualmente
	-- atributos fixos na instanciação
	player.vel = 280                       -- velocidade em pixels por segundo
	player.size = { height = 32, width = 32 } -- em pixels
	player.movementVec = { x = 0, y = 0 }  -- vetor de direção e magnitude do movimento do jogador
	player.state = IDLE                    -- define o estado atual do jogador, estreitamente relacionado às animações
	player.spriteSheets = {}               -- no tipo imagem do love
	player.animations = {}                 -- as chaves são estados e os valores são Animações
	player.weapons = {}                    -- lista das armas que o jogador possui
	player.weapon = nil                    -- arma equipada

	return player
end

function Player:addAnimations()
	local source = "assets/animations/" .. string.lower(self.name)
	local quadSize = { width = 32, height = 32 }
	-- animação idle
	local idlePath = source .. "/idle.png"
	local idleAnimation = newAnimation(idlePath, 2, quadSize, 0.5, true, 1, quadSize)
	self.animations[IDLE] = idleAnimation
	self.spriteSheets[IDLE] = love.graphics.newImage(idlePath)
	self.spriteSheets[IDLE]:setFilter("nearest", "nearest")
	-- animação defesa
	local defPath = source .. "/defense.png"
	local defAnimation = newAnimation(defPath, 15, quadSize, 0.05, true, 12, quadSize)
	self.animations[DEFENDING] = defAnimation
	self.spriteSheets[DEFENDING] = love.graphics.newImage(defPath)
	self.spriteSheets[DEFENDING]:setFilter("nearest", "nearest")
	-- animação andar para cima
	local wUpPath = source .. "/walk_up.png"
	local wUpAnimation = newAnimation(wUpPath, 4, quadSize, 0.25, true, 1, quadSize)
	self.animations[WALKING_UP] = wUpAnimation
	self.spriteSheets[WALKING_UP] = love.graphics.newImage(wUpPath)
	self.spriteSheets[WALKING_UP]:setFilter("nearest", "nearest")
	-- animação andar para baixo
	local wDownPath = source .. "/walk_down.png"
	local wDownAnimation = newAnimation(wDownPath, 4, quadSize, 0.25, true, 1, quadSize)
	self.animations[WALKING_DOWN] = wDownAnimation
	self.spriteSheets[WALKING_DOWN] = love.graphics.newImage(wDownPath)
	self.spriteSheets[WALKING_DOWN]:setFilter("nearest", "nearest")
	-- animação andar para esquerda
	local wLeftPath = source .. "/walk_left.png"
	local wLeftAnimation = newAnimation(wLeftPath, 4, quadSize, 0.25, true, 1, quadSize)
	self.animations[WALKING_LEFT] = wLeftAnimation
	self.spriteSheets[WALKING_LEFT] = love.graphics.newImage(wLeftPath)
	self.spriteSheets[WALKING_LEFT]:setFilter("nearest", "nearest")
	-- animação andar para direita
	local wRightPath = source .. "/walk_right.png"
	local wRightAnimation = newAnimation(wRightPath, 4, quadSize, 0.25, true, 1, quadSize)
	self.animations[WALKING_RIGHT] = wRightAnimation
	self.spriteSheets[WALKING_RIGHT] = love.graphics.newImage(wRightPath)
	self.spriteSheets[WALKING_RIGHT]:setFilter("nearest", "nearest")
end

function Player:move(dt)
	self.movementVec = { x = 0, y = 0 }
	if love.keyboard.isDown(self.controls.up) then
		self.movementVec.y = self.movementVec.y - dt * self.vel
	end
	if love.keyboard.isDown(self.controls.down) then
		self.movementVec.y = self.movementVec.y + dt * self.vel
	end
	if love.keyboard.isDown(self.controls.left) then
		self.movementVec.x = self.movementVec.x - dt * self.vel
	end
	if love.keyboard.isDown(self.controls.right) then
		self.movementVec.x = self.movementVec.x + dt * self.vel
	end

	if self.movementVec.x == 0 and self.movementVec.y == 0 then
		return
	end

	normalize(self.movementVec)
	self.movementVec.x = self.movementVec.x * dt * self.vel
	self.movementVec.y = self.movementVec.y * dt * self.vel
	self.pos.x = self.pos.x + self.movementVec.x
	self.pos.y = self.pos.y + self.movementVec.y

	self.weapon:updateOrientation({ x = self.movementVec.x, y = self.movementVec.y })
	self:updateRoom()
end

function Player:updateRoom()
	local roomX = self.room.pos.x
	local roomY = self.room.pos.y

	-- o jogador foi para a sala à esquerda
	if self.pos.x < self.room.hitbox.p1.x then
		self.room = rooms[roomY][roomX - 1]
	end
	-- o jogador foi para a sala à direita
	if self.pos.x > self.room.hitbox.p2.x then
		self.room = rooms[roomY][roomX + 1]
	end
	-- o jogador foi para a sala acima
	if self.pos.y < self.room.hitbox.p1.y then
		self.room = rooms[roomY - 1][roomX]
	end
	-- o jogador foi para a sala abaixo
	if self.pos.y > self.room.hitbox.p2.y then
		self.room = rooms[roomY + 1][roomX]
	end

	self.room:setExplored()
end

function Player:updateState()
	local prevState = self.state
	if love.keyboard.isDown(self.controls.act2) then
		self.state = DEFENDING
	else
		if self.movementVec.y < 0 then
			self.state = WALKING_UP
		elseif self.movementVec.x > 0 then
			self.state = WALKING_RIGHT
		elseif self.movementVec.x < 0 then
			self.state = WALKING_LEFT
		elseif self.movementVec.y > 0 then
			self.state = WALKING_DOWN
		else
			self.state = IDLE
		end
	end
	-- resetando a animação anterior, caso o estado tenha mudado
	if self.state ~= prevState then
		self.animations[prevState]:reset()
	end
end

function Player:checkAction1(key)
	if key == self.controls.act1 then
		self:attack()
	end
end

function Player:collectWeapon(weapon)
	table.insert(self.weapons, weapon)
end

function Player:equipWeapon(weapon)
	-- itera pelas armas do jogador procurando pela que ele quer equipar
	for _, w in pairs(self.weapons) do
		if w.type == weapon then
			self.weapon = w
		end
	end
end

function Player:attack()
	if self.weapon then
		self.weapon:attack()
	end
end

----------------------------------------
-- Funções Globais
----------------------------------------
function newPlayer()
	-- limite de jogadores alcançado
	if #players >= 4 then
		return false
	end

	if #players == 0 then
		player1 = Player.new(
			1,
			"Mush",
			{ x = window.width / 2, y = window.height / 2 },
			{ up = "w", left = "a", down = "s", right = "d", act1 = "space", act2 = "lshift" },
			{ r = 1.0, g = 0.7, b = 0.7, a = 1.0 },
			rooms[0][0]
		)
		player1:addAnimations()
		table.insert(players, player1)
	elseif #players == 1 then
		player2 = Player.new(
			2,
			"Shroom",
			{ x = player1.pos.x + 75, y = player1.pos.y },
			{ up = "up", left = "left", down = "down", right = "right", act1 = "rctrl", act2 = "rshift" },
			{ r = 0.7, g = 0.7, b = 1.0, a = 1.0 },
			players[1].room
		)
		player2:addAnimations()
		table.insert(players, player2)
	elseif #players == 2 then
		player3 = Player.new(
			3,
			"Musho",
			{ x = player1.pos.x + 75, y = player1.pos.y },
			{ up = "t", left = "f", down = "g", right = "h", act1 = "r", act2 = "y" },
			{ r = 1.0, g = 0.7, b = 1.0, a = 1.0 },
			players[1].room
		)
		player3:addAnimations()
		table.insert(players, player3)
	else
		player4 = Player.new(
			4,
			"Roomy",
			{ x = player1.pos.x + 75, y = player1.pos.y },
			{ up = "i", left = "j", down = "k", right = "l", act1 = "u", act2 = "o" },
			{ r = 0.7, g = 1.0, b = 1.0, a = 1.0 },
			players[1].room
		)
		player4:addAnimations()
		table.insert(players, player4)
	end
	newCamera()
end

return Player
