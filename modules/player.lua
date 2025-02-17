----------------------------------------
-- Importações de Módulos
----------------------------------------
require "modules/utils"
require "table"

----------------------------------------
-- Classe Player
----------------------------------------
Player = {}
Player.__index = Player

-- Construtor
function Player.new(id, name, assets, spawn_pos, controls)
	local player = setmetatable({}, Player)

	-- atributos que variam
	player.id = id             -- número do jogador
	player.name = name         -- nome do jogador
	player.assets = assets     -- caminho até a pasta contendo os assets do jogador
	player.pos = spawn_pos     -- posição para spawnar o jogador
	player.controls = controls -- os comandos para controlar o boneco, no formato {up = "", left = "", down = "", right = "", action = ""}
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
	for k, v in pairs(self.movementDirections) do
		print(k..": ".."v")
	end
end

function Player:move(dt)
	local displacement
	
	local directions = {}
	for k, v in pairs(self.movementDirections) do
		print(v)
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
end

return Player