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
Room.stdDimensions = {width = 600, height = 600}

function Room.new(pos, dimensions, hitbox, type, color)
	local room = setmetatable({}, Room)

	-- atributos que variam
	room.pos = pos
	room.dimensions = dimensions
	room.hitbox = hitbox
	room.type = type
	room.color = color
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
			newRoom(pos, Room.stdDimensions, math.random(0, 2))
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
		color = {r = 1.0, g = 0.69, b = 0.47, a = 1.0}
	elseif type == 1 then
		color = {r = 0.96, g = 0.95, b = 0.42, a = 1.0}
	elseif type == 2 then
		color = {r = 0.97, g = 0.34, b = 0.61, a = 1.0}
	end

	local p1 = {x = pos.x * 600 + 100,
                y = pos.y * 600 + 100}
    local p2 = {x = p1.x + dimensions.width,
				y = p1.y + dimensions.height}
	local hitbox = {p1 = p1, p2 = p2}

	local r = Room.new(pos, dimensions, hitbox, type, color)
	rooms[pos.y]:insert(pos.x, r)
end

function createInitialRoom()
	newRoom({x = 0, y = 0}, Room.stdDimensions, 0)
end

-- calcula as posições dos pontos superior esquerdo e inferior direito da sala
-- nas coordenadas de mundo
function calculateRoomLimits(r)
	local p1 = {x = r.pos.x * 610 + 100,
	            y = r.pos.y * 610 + 100}
	local p2 = {x = p1.x + r.dimensions.width,
				y = p1.y + r.dimensions.height}
	return {p1 = p1, p2 = p2}
end