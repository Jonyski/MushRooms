----------------------------------------
-- Importações de Módulos
----------------------------------------
require("table")
require("modules.utils.utils")
require("modules.systems.blueprints")
require("modules.utils.types")
require("modules.utils.constructors")

----------------------------------------
-- Variáveis e enums
----------------------------------------
rooms = BiList.new()
activeRooms = Set.new()

-- tipos de sala
PUZZLE_ROOM = "puzzle room"
NPC_ROOM = "npc room"
RESOURCE_ROOM = "resource room"
BATTLE_ROOM = "battle room"
BOSS_ROOM = "boss room"
EVENT_ROOM = "event room"

---@alias RoomType
---| `PUZZLE_ROOM`
---| `NPC_ROOM`
---| `RESOURCE_ROOM`
---| `BATTLE_ROOM`
---| `BOSS_ROOM`
---| `EVENT_ROOM`

---@class RoomLimits
---@field p1 Vec
---@field p2 Vec

----------------------------------------
-- Classe Room
----------------------------------------

---@class Room
---@field pos Vec
---@field dimensions Size
---@field center Vec
---@field color Color
---@field sprites table
---@field explored boolean
---@field destructibles Destructible[]
---@field items Item[]
---@field enemies Enemy[]
---@field npcs Npc[]
---@field playersInRoom Set
---@field populate function
---@field visit function

Room = {}
Room.__index = Room
Room.stdDim = { width = 1536, height = 1536 }
Room.type = ROOM

---@param pos Vec
---@param dimensions Size
---@param roomLimits RoomLimits
---@param blueprint Blueprint
---@param sprites table
---@return Room
-- cria uma instância de `Room`
function Room.new(pos, dimensions, roomLimits, blueprint, sprites)
	local room = setmetatable({}, Room)

	-- atributos que variam
	room.pos = pos                                    -- posição da sala na array de salas
	room.dimensions = dimensions                      -- largura e altura da sala
	room.hitbox = roomLimits                          -- pontos superior esquerdo (p1) e inferior direito (p2) da sala
	room.center = midpoint(roomLimits.p1, roomLimits.p2) -- ponto central da sala
	room.color = blueprint.color                      -- cor da sala
	room.sprites = sprites                            -- os sprites da sala em camadas
	-- atributos fixos na instanciação
	room.explored = false                             -- se algum jogador já entrou na sala ou não
	room.destructibles = {}                           -- lista de objetos destrutíveis da sala
	room.items = {}                                   -- lista de itens dropados na sala
	room.enemies = {}                                 -- lista de inimigos na sala
	room.npcs = {}                                    -- lista de NPCs na sala
	room.playersInRoom = Set.new()                    -- lista de jogadores na sala

	return room
end

---@param dt number
-- atualiza os destrutíveis, inimigos e items da sala
function Room:update(dt)
	-- atualiza destrutíveis
	for _, d in pairs(self.destructibles) do
		d:update(dt)
	end
	-- atualiza items
	for _, item in pairs(self.items) do
		item:update(dt)
	end
	-- atualiza inimigos
	for _, e in pairs(self.enemies) do
		e:update(dt)
	end
	-- atualiza NPCs
	for _, npc in pairs(self.npcs) do
		npc:update(dt)
	end
end

---@param player Player
-- adiciona `Room` à lista de salas ativas
function Room:visit(player)
	if self.playersInRoom:has(player.id) then
		return
	end

	self.playersInRoom:add(player.id, player)
	activeRooms:add(makeKey(self.pos.x, self.pos.y), self)
end

-- define a sala como estando explorada, gerando as 4 salas
-- vizinhas à ela
function Room:setExplored()
	if not self.explored then
		self.explored = true

		-- criando salas adjacentes se eles ainda não existem
		local adjacentPos = self:getAdjacentPos()
		for _, pos in pairs(adjacentPos) do
			if not rooms[pos.y] then
				rooms:insert(pos.y, BiList.new())
			end
			if not rooms[pos.y][pos.x] then
				newRoom(pos, Room.stdDim)
			end
		end
	end
end

---@return Vec[]
-- retorna as posições das 4 salas adjacentes em uma lista
-- essa função existe mais por praticidade
function Room:getAdjacentPos()
	local adjacentPos = {}
	table.insert(adjacentPos, { x = self.pos.x - 1, y = self.pos.y })
	table.insert(adjacentPos, { x = self.pos.x + 1, y = self.pos.y })
	table.insert(adjacentPos, { x = self.pos.x, y = self.pos.y - 1 })
	table.insert(adjacentPos, { x = self.pos.x, y = self.pos.y + 1 })
	return adjacentPos
end

-- se a sala está vazia (sem jogadores), remove ela da lista de salas ativas
function Room:verifyIsEmpty()
	if self.playersInRoom:size() == 0 then
		activeRooms:remove(makeKey(self.pos.x, self.pos.y))
	end
end

---@param spawnpoints SpawnPoint[]
-- geração dos conteúdos de uma sala
function Room:populate(spawnpoints)
	for _, sp in pairs(spawnpoints) do
		local n = math.random()
		for _, sd in ipairs(sp.spawns) do
			if n < sd.chance then
				self:spawn(sd.entity, sp.pos)
				goto nextspawnpoint
			end
		end
		::nextspawnpoint::
	end
end

---@param entity any
---@param pos Vec
-- instancia uma entidade e a insere na lista correspondente da sala
function Room:spawn(entity, pos)
	print("Tipo: " .. entity.type .. " Nome: " .. entity.name)
	local constructor = CONSTRUCTORS[entity.type][entity.name]
	local real_pos = addVec(pos, self.center)
	if entity.type == ENEMY then
		table.insert(self.enemies, constructor(real_pos, self))
	elseif entity.type == DESTRUCTIBLE then
		table.insert(self.destructibles, constructor(real_pos, self))
	elseif entity.type == NPC then
		table.insert(self.npcs, constructor(real_pos, self))
	end
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@param pos any
---@param dimensions any
-- cria uma nova sala no índice indicado por `pos` da
-- lista global de salas (`rooms`)
function newRoom(pos, dimensions)
	if not rooms[pos.y] then
		rooms:insert(pos.y, BiList.new())
	end
	-- escolhendo uma blueprint para a sala
	local roomType = randRoomType()
	local blueprint = randRoomBlueprint(roomType)
	-- gerando os atributos derivadoss
	local p1 = vec(pos.x * Room.stdDim.width, pos.y * Room.stdDim.height)
	local p2 = vec(p1.x + dimensions.width, p1.y + dimensions.height)
	local hitbox = { p1 = p1, p2 = p2 }
	local sprites = {}
	sprites.floor = love.graphics.newImage("assets/sprites/rooms/testRoom.png")
	sprites.floor:setFilter("nearest", "nearest")
	-- instanciando e populando com entidades (inimigos, destrutíveis, etc)
	local room = Room.new(pos, dimensions, hitbox, blueprint, sprites)
	room:populate(blueprint.spawnpoints)
	rooms[pos.y]:insert(pos.x, room)
end

-- cria a sala inicial do jogo e suas 4 vizinhas
function createInitialRooms()
	-- cria a sala inicial do jogo e suas vizinhas
	newRoom({ x = 0, y = 0 }, Room.stdDim)
	rooms[0][0]:setExplored()
end

---@param room Room
---@return table
-- calcula as posições dos pontos superior esquerdo e inferior direito da sala
-- nas coordenadas de mundo
function calculateRoomLimits(room)
	local p1 = {
		x = room.pos.x * Room.stdDim.width - 265,
		y = room.pos.y * Room.stdDim.height - 260,
	}
	local p2 = {
		x = p1.x + room.dimensions.width,
		y = p1.y + room.dimensions.height,
	}
	return { p1 = p1, p2 = p2 }
end

---@param x number
---@param y number
---@return string
-- cria uma key única baseada nas coordenadas da sala
function makeKey(x, y)
	return tostring(x) .. "," .. tostring(y)
end

return Room
