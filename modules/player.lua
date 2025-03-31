----------------------------------------
-- Importações de Módulos
----------------------------------------
require "modules/utils"
require "table"

----------------------------------------
-- Variáveis
----------------------------------------
players = {}

----------------------------------------
-- Classe Player
----------------------------------------
Player = {}
Player.__index = Player

-- Construtor
function Player.new(id, name, assets, spawn_pos, controls, color, room)
	local player = setmetatable({}, Player)

	-- atributos que variam
	player.id = id             -- número do jogador
	player.name = name         -- nome do jogador
	player.assets = assets     -- caminho até a pasta contendo os assets do jogador
	player.pos = spawn_pos     -- posição para spawnar o jogador
	player.controls = controls -- os comandos para controlar o boneco, no formato {up = "", left = "", down = "", right = "", action = ""}
	player.color = color       -- cor que representa o jogador
	player.room = room         -- sala na qual o jogador está atualmente
	-- atributos fixos na instanciação
	player.vel = 200                        -- velocidade em pixels por segundo
	player.size = {height = 32, width = 32} -- em pixels
	player.movementDirections = {}          -- tabela com as direções de movimento atualmente ativas
	return player
end

function Player:checkMovement(key, type)
	if type == "press" then
		if key == self.controls.up and not tableFind(self.movementDirections, UP) then
			table.insert(self.movementDirections, UP)
		elseif key == self.controls.left and not tableFind(self.movementDirections, LEFT) then
			table.insert(self.movementDirections, LEFT)
		elseif key == self.controls.down and not tableFind(self.movementDirections, DOWN) then
			table.insert(self.movementDirections, DOWN)
		elseif key == self.controls.right and not tableFind(self.movementDirections, RIGHT) then
			table.insert(self.movementDirections, RIGHT)
		end
	elseif type == "release" then
		if key == self.controls.up and tableFind(self.movementDirections, UP) then
			self.movementDirections[tableFind(self.movementDirections, UP)] = nil
		elseif key == self.controls.left and tableFind(self.movementDirections, LEFT) then
			self.movementDirections[tableFind(self.movementDirections, LEFT)] = nil
		elseif key == self.controls.down and tableFind(self.movementDirections, DOWN) then
			self.movementDirections[tableFind(self.movementDirections, DOWN)] = nil
		elseif key == self.controls.right and tableFind(self.movementDirections, RIGHT) then
			self.movementDirections[tableFind(self.movementDirections, RIGHT)] = nil
		end
	end
end

function Player:move(dt)
	local displacement
	
	local directions = {}
	for k, v in pairs(self.movementDirections) do
		table.insert(directions, v)
	end
	
	if tableFind(directions, UP) and tableFind(directions, DOWN) then
		directions[tableFind(directions, UP)] = nil
		directions[tableFind(directions, DOWN)] = nil
	end
	if tableFind(directions, LEFT) and tableFind(directions, RIGHT) then
		directions[tableFind(directions, LEFT)] = nil
		directions[tableFind(directions, RIGHT)] = nil
	end

	-- player isn't moving
	if #directions == 0 then return end
	-- player is moving in one direction
	if #directions == 1 then
		displacement = dt * self.vel
	-- player is moving diagonally
	elseif #directions == 2 then
		displacement = dt * self.vel / 1.41421
	end

	-- update player's position
	if tableFind(directions, UP) then
		self.pos.y = self.pos.y - displacement
	end
	if tableFind(directions, LEFT) then
		self.pos.x = self.pos.x - displacement
	end
	if tableFind(directions, DOWN) then
		self.pos.y = self.pos.y + displacement
	end
	if tableFind(directions, RIGHT) then
		self.pos.x = self.pos.x + displacement
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



----------------------------------------
-- Funções Goblais
----------------------------------------
function newPlayer()
	-- limite de jogadores alcançado
	if #players >= 4 then return false end

	if #players == 0 then
		player1 = Player.new(1,
		                     "Mush",
		                     "assets/player1/",
		                     {x = window.width / 2, y = window.height / 2},
		                     {up = "w", left = "a", down = "s", right = "d", act1 = "space", act2 = "lshift"},
							 {r = 1.0, g = 0.7, b = 0.7, a = 1.0},
							 rooms[0][0])
		table.insert(players, player1)
	elseif #players == 1 then
		player2 = Player.new(2,
		                     "Shroom",
		                     "assets/player2/",
		                     {x = player1.pos.x + 75, y = player1.pos.y},
		                     {up = "up", left = "left", down = "down", right = "right", act1 = "rctrl", act2 = "rshift"},
							 {r = 0.7, g = 0.7, b = 1.0, a = 1.0},
							 players[1].room)
		table.insert(players, player2)
	elseif #players == 2 then
		player3 = Player.new(3,
		                     "Musho",
		                     "assets/player3/",
		                     {x = player1.pos.x + 75, y = player1.pos.y},
		                     {up = "t", left = "f", down = "g", right = "h", act1 = "r", act2 = "y"},
							 {r = 1.0, g = 0.7, b = 1.0, a = 1.0},
							 players[1].room)
		table.insert(players, player3)
	else
		player4 = Player.new(4,
		                     "Roomy",
		                     "assets/player4/",
		                     {x = player1.pos.x + 75, y = player1.pos.y},
		                     {up = "i", left = "j", down = "k", right = "l", act1 = "u", act2 = "o"},
							 {r = 0.7, g = 1.0, b = 1.0, a = 1.0},
							 players[1].room)
		table.insert(players, player4)
	end
	newCamera()
end

return Player