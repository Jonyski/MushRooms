----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")

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
	return Blueprint.new(PUZZLE_ROOM, "Test Puzzle Room", Color.new(12, 253, 255, 255))
end

function randNPCRoomBP()
	local bp = Blueprint.new(NPC_ROOM, "Test NPC Room", Color.new(120, 58, 242, 255))
	local sp1 = SpawnPoint.new(vec(100, 0))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, 0))
	local barrelData = SpawnData.new(BARREL, 0.5)
	local jarData = SpawnData.new(JAR, 0.8)
	sp1:insert(barrelData):insert(jarData)
	sp2:insert(barrelData):insert(jarData)
	sp3:insert(barrelData):insert(jarData)
	bp:insert(sp1):insert(sp2):insert(sp3)
	return bp
end

function randResourceRoomBP()
	local bp = Blueprint.new(RESOURCE_ROOM, "Test Resource Room", Color.new(255, 248, 122, 255))
	local sp1 = SpawnPoint.new(vec(100, 0))
	local sp2 = SpawnPoint.new(vec(200, 0))
	local sp3 = SpawnPoint.new(vec(300, 0))
	local sp4 = SpawnPoint.new(vec(400, 0))
	local barrelData = SpawnData.new(BARREL, 0.5)
	local jarData = SpawnData.new(JAR, 1.0)
	sp1:insert(barrelData):insert(jarData)
	sp2:insert(barrelData):insert(jarData)
	sp3:insert(barrelData):insert(jarData)
	sp4:insert(barrelData):insert(jarData)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	return bp
end

function randBattleRoomBP()
	local bp = Blueprint.new(BATTLE_ROOM, "Test Battle Room", Color.new(255, 255, 255, 255))
	local sp1 = SpawnPoint.new(vec(100, -100))
	local sp2 = SpawnPoint.new(vec(-100, 100))
	local sp3 = SpawnPoint.new(vec(100, 100))
	local sp4 = SpawnPoint.new(vec(-100, -100))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.5)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(enemyData1):insert(enemyData2)
	sp2:insert(enemyData1):insert(enemyData2)
	sp3:insert(enemyData1):insert(enemyData2)
	sp4:insert(enemyData1):insert(enemyData2)
	bp:insert(sp1):insert(sp2):insert(sp3):insert(sp4)
	return bp
end

function randBossRoomBP()
	local bp = Blueprint.new(BOSS_ROOM, "Test Boss Room", Color.new(255, 41, 41, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.5)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(enemyData1):insert(enemyData2)
	bp:insert(sp1)
	return bp
end

function randEventRoomBP()
	local bp = Blueprint.new(EVENT_ROOM, "Test Event Room", Color.new(104, 237, 102, 255))
	local sp1 = SpawnPoint.new(vec(0, 0))
	local barrelData = SpawnData.new(BARREL, 0.25)
	local jarData = SpawnData.new(JAR, 0.5)
	local enemyData1 = SpawnData.new(SPIDER_DUCK, 0.75)
	local enemyData2 = SpawnData.new(NUCLEAR_CAT, 1.0)
	sp1:insert(barrelData):insert(jarData):insert(enemyData1):insert(enemyData2)
	bp:insert(sp1)
	return bp
end
