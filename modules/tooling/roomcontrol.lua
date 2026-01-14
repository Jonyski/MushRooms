----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.room")
require("modules.systems.blueprints")
require("modules.utils.utils")

----------------------------------------
-- Funções de debug
----------------------------------------

function _roomCondition()
	return love.keyboard.isDown("r")
end

function _roomDebugHandler(numberKey)
	local roomChange = false

	local debugRoomPos = { x = players[1].room.pos.x + 1, y = players[1].room.pos.y }
	if numberKey == "1" then
		_newRoomDebug(debugRoomPos, Room.stdDim, BATTLE_ROOM)
		roomChange = true
	elseif numberKey == "2" then
		_newRoomDebug(debugRoomPos, Room.stdDim, NPC_ROOM)
		roomChange = true
	elseif numberKey == "3" then
		_newRoomDebug(debugRoomPos, Room.stdDim, RESOURCE_ROOM)
		roomChange = true
	elseif numberKey == "4" then
		_newRoomDebug(debugRoomPos, Room.stdDim, PUZZLE_ROOM)
		roomChange = true
	elseif numberKey == "5" then
		_newRoomDebug(debugRoomPos, Room.stdDim, EVENT_ROOM)
		roomChange = true
	elseif numberKey == "6" then
		_newRoomDebug(debugRoomPos, Room.stdDim, BOSS_ROOM)
		roomChange = true
	end
	if roomChange then
		collisionManager.roomsDirty = true
	end
	return roomChange
end

function _newRoomDebug(pos, dimensions, roomType)
	if not rooms[pos.y] then
		rooms:insert(pos.y, BiList.new())
	end
	local blueprint = randRoomBlueprint(roomType)
	local p1 = vec(pos.x * Room.stdDim.width, pos.y * Room.stdDim.height)
	local p2 = vec(p1.x + dimensions.width, p1.y + dimensions.height)
	local hitbox = { p1 = p1, p2 = p2 }
	local sprites = {}
	sprites.floor = love.graphics.newImage("assets/sprites/rooms/testRoom.png")
	sprites.floor:setFilter("nearest", "nearest")
	local room = Room.new(pos, dimensions, hitbox, blueprint, sprites)
	room:populate(blueprint.spawnpoints)
	rooms[pos.y]:insert(pos.x, room)
end
