----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules/utils")
require("modules/animation")
require("modules/vec")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------
players = {}

-- Cada estado está relacionado a uma animação do cogumelinho
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
	player.id = id -- número do jogador
	player.name = name -- nome do jogador
	player.pos = spawn_pos -- posição do jogador (inicializa para a posição do spawn)
	player.controls = controls -- os comandos para controlar o boneco, no formato {up = "", left = "", down = "", right = "", action = ""}
	player.color = color -- cor que representa o jogador
	player.room = room -- sala na qual o jogador está atualmente
	-- atributos fixos na instanciação
	player.vel = 280 -- velocidade em pixels por segundo
	player.size = { height = 32, width = 32 } -- em pixels
	player.movementVec = { x = 0, y = 0 } -- vetor de direção e magnitude do movimento do jogador
	player.state = IDLE -- define o estado atual do jogador, estreitamente relacionado às animações
	player.spriteSheets = {} -- no tipo imagem do love
	player.animations = {} -- as chaves são estados e os valores são Animações
	player.weapons = {} -- lista das armas que o jogador possui
	player.weapon = nil -- arma equipada

	return player
end

function Player:addAnimations()
	-- animação idle
	self:addAnimation(IDLE, 2, 0.5, true, 1)
	-- animação defesa
	self:addAnimation(DEFENDING, 15, 0.05, true, 12)
	-- animação andar para cima
	self:addAnimation(WALKING_UP, 4, 0.25, true, 1)
	-- animação andar para baixo
	self:addAnimation(WALKING_DOWN, 4, 0.25, true, 1)
	-- animação andar para esquerda
	self:addAnimation(WALKING_LEFT, 4, 0.25, true, 1)
	-- animação andar para direita
	self:addAnimation(WALKING_RIGHT, 4, 0.25, true, 1)
end

function Player:addAnimation(action, numFrames, frameDur, looping, loopFrame)
	local path = "assets/animations/players/" .. string.lower(self.name) .. "/" .. action:gsub(" ", "_") .. ".png"
	local quadSize = { width = 32, height = 32 }
	local animation = newAnimation(path, numFrames, quadSize, frameDur, looping, loopFrame, quadSize)
	self.animations[action] = animation
	self.spriteSheets[action] = love.graphics.newImage(path)
	self.spriteSheets[action]:setFilter("nearest", "nearest")
end

function Player:move(dt)
	self.movementVec = { x = 0, y = 0 }

	if self.state == DEFENDING then
		return
	end
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

	-- Normalizando para impedir movimentos na diagonal de serem mais rápidos
	normalize(self.movementVec)
	-- Levando o dt e a velocidade do cogumelo em consideração
	self.movementVec.x = self.movementVec.x * dt * self.vel
	self.movementVec.y = self.movementVec.y * dt * self.vel
	self.pos.x = self.pos.x + self.movementVec.x
	self.pos.y = self.pos.y + self.movementVec.y

	if self.weapon then
		self.weapon:updateOrientation({ x = self.movementVec.x, y = self.movementVec.y })
	end
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

function Player:draw(camera)
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
-- Funções Globais
----------------------------------------
function newPlayer()
	-- limite de jogadores alcançado
	if #players >= 4 then
		return false
	end

	if #players == 0 then
		-- o +365 e +350 são números mágicos para centralizar o player 1 na sala inicial
		local firstSpawnPoint = { x = window.width / 2 + 365, y = window.height / 2 + 350 }
		player1 = Player.new(
			1,
			"Mush",
			firstSpawnPoint,
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
