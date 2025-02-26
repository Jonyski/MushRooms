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

function Room.new(pos, dimensions, type, color)
	local room = setmetatable({}, Room)

	-- atributos que variam
	room.pos = pos
	room.dimensions = dimensions
	room.type = type
	room.color = color
	-- atributos fixos na instanciação
	-- ...

	return room
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

	local r = Room.new(pos, dimensions, type, color)
	rooms[pos.y]:insert(pos.x, r)
end

function createInitialRooms()
	for i = -5, 5 do
		for j = -5, 5 do
			local dimensions = {width = 390, height = 390}
			local pos = {x = j, y = i}
			newRoom(pos, dimensions, math.abs(math.fmod(i + j, 3)))
		end
	end
end