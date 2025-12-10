----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.entities.constructors.room")

----------------------------------------
-- Classe SpawnData
----------------------------------------
SpawnData = {}
SpawnData.__index = SpawnData
SpawnData.type = SPAWN_DATA

-- um dado de spawn nos dá uma forma de descobrir o que será
-- instanciado e com qual chance em cada spawnpoint
function SpawnData.new(entity, chance)
	local data = setmetatable({}, SpawnData)
	data.entity = entity
	data.chance = chance
	return data
end

----------------------------------------
-- Classe SpawnPoint
----------------------------------------
SpawnPoint = {}
SpawnPoint.__index = SpawnPoint
SpawnPoint.type = SPAWNPOINT

-- um spawn point agrega uma lista de objetos que podem
-- spawnar naquela posição e com qual chance
function SpawnPoint.new(pos)
	local sp = setmetatable({}, SpawnPoint)
	sp.pos = pos -- posição do spawnpoint na sala
	sp.spawns = {} -- lista de SpawnDatas relacionados a este spawn point
	return sp
end

function SpawnPoint:insert(spawnData)
	if not spawnData then
		return
	end
	table.insert(self.spawns, spawnData)
	return self
end

----------------------------------------
-- Classe Blueprint
----------------------------------------
Blueprint = {}
Blueprint.__index = Blueprint
Blueprint.type = BLUEPRINT

-- A blueprint armazena informações gerais sobre
-- uma sala e uma lista de spawn points
function Blueprint.new(roomType, roomName, color)
	local bp = setmetatable({}, Blueprint)
	bp.roomType = roomType
	bp.roomName = roomName
	bp.color = color
	bp.spawnpoints = {}
	return bp
end

function Blueprint:insert(spawnpoint)
	if not spawnpoint then
		return
	end
	table.insert(self.spawnpoints, spawnpoint)
	return self
end

----------------------------------------
-- Funções globais
----------------------------------------
function randRoomType()
	local r = math.random()
	if r < 0.66 then
		return BATTLE_ROOM -- Sala de combate: 66%
	elseif r < 0.78 then
		return RESOURCE_ROOM -- Sala de recurso: 12%
	elseif r < 0.86 then
		return EVENT_ROOM -- Sala de evento: 8%
	elseif r < 0.94 then
		return NPC_ROOM -- Sala de NPC: 8%
	elseif r < 0.98 then
		return PUZZLE_ROOM -- Sala de puzzle: 4%
	else
		return BOSS_ROOM -- Sala de boss: 2%
	end
end

function randRoomBlueprint(roomType)
	if roomType == PUZZLE_ROOM then
		return randPuzzleRoomBP()
	elseif roomType == NPC_ROOM then
		return randNPCRoomBP()
	elseif roomType == RESOURCE_ROOM then
		return randResourceRoomBP()
	elseif roomType == BATTLE_ROOM then
		return randBattleRoomBP()
	elseif roomType == BOSS_ROOM then
		return randBossRoomBP()
	elseif roomType == EVENT_ROOM then
		return randEventRoomBP()
	end
end

-- TODO: criar mais blueprints e tornar estas funções aleatórias

function randPuzzleRoomBP()
	return newPuzzleRoom1()
end

function randNPCRoomBP()
	return newNPCRoom1()
end

function randResourceRoomBP()
	return newResourceRoom1()
end

function randBattleRoomBP()
	return newBattleRoom1()
end

function randBossRoomBP()
	return newBossRoom1()
end

function randEventRoomBP()
	return newEventRoom1()
end
