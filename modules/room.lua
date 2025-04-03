----------------------------------------
-- Importações de Módulos
----------------------------------------
require "table"
require "modules/utils"

----------------------------------------
-- Variáveis
----------------------------------------
rooms = BiList.new()

----------------------------------------
-- Classe Player
----------------------------------------
Room = {}
Room.__index = Room
Room.stdDim = {width = 1536, height = 1536}

function Room.new(pos, dimensions, hitbox, type, color, sprites)
	local room = setmetatable({}, Room)

	-- atributos que variam
	room.pos = pos
	room.dimensions = dimensions
	room.hitbox = hitbox
	room.type = type
	room.color = color
	room.sprites = sprites
	-- atributos fixos na instanciação
	room.explored = false

	return room
end

function Room:setExplored()
	self.explored = true
	-- criando salas adjacentes se eles ainda não existem
	local adjacentPos = self:getAdjacentPos()
	for _, pos in pairs(adjacentPos) do
		if not rooms[pos.y] then
			rooms:insert(pos.y, BiList.new())
		end
		if not rooms[pos.y][pos.x] then
			newRoom(pos, Room.stdDim, love.math.random(0, 2))
		end
	end
end

-- retorna as posições das 4 salas adjacentes em uma lista
-- essa função existe mais por praticidade
function Room:getAdjacentPos()
	local adjacentPos = {}
	table.insert(adjacentPos, {x = self.pos.x - 1, y = self.pos.y})
	table.insert(adjacentPos, {x = self.pos.x + 1, y = self.pos.y})
	table.insert(adjacentPos, {x = self.pos.x, y = self.pos.y - 1})
	table.insert(adjacentPos, {x = self.pos.x, y = self.pos.y + 1})
	return adjacentPos
end

----------------------------------------
-- Funções Globais
----------------------------------------
function newRoom(pos, dimensions, type)
	if not rooms[pos.y] then
		rooms:insert(pos.y, BiList.new())
	end
	
	local color = {}
	if type == 0 then
		color = {r = 0.7, g = 0.7, b = 1.0, a = 1.0}
	elseif type == 1 then
		color = {r = 1.0, g = 0.7, b = 0.7, a = 1.0}
	elseif type == 2 then
		color = {r = 0.7, g = 0.7, b = 0.7, a = 1.0}
	end

	local p1 = {x = pos.x * Room.stdDim.width - 365,
                y = pos.y * Room.stdDim.height - 360}
    local p2 = {x = p1.x + dimensions.width,
				y = p1.y + dimensions.height}
	local hitbox = {p1 = p1, p2 = p2}
	local sprites = {}
	sprites.floor = love.graphics.newImage("assets/sprites/rooms/testRoom.png")
	sprites.floor:setFilter("nearest", "nearest")
	local r = Room.new(pos, dimensions, hitbox, type, color, sprites)
	rooms[pos.y]:insert(pos.x, r)
end

function createInitialRooms()
	newRoom({x = 0, y = 0}, Room.stdDim, 0)
	rooms[0][0]:setExplored()
end

-- calcula as posições dos pontos superior esquerdo e inferior direito da sala
-- nas coordenadas de mundo
function calculateRoomLimits(r)
	local p1 = {x = r.pos.x * Room.stdDim.width + 100,
	            y = r.pos.y * Room.stdDim.height + 100}
	local p2 = {x = p1.x + r.dimensions.width,
				y = p1.y + r.dimensions.height}
	return {p1 = p1, p2 = p2}
end

return Room