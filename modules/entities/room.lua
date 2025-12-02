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

----------------------------------------
-- Classe Room
----------------------------------------
Room = {}
Room.__index = Room
Room.stdDim = { width = 1536, height = 1536 }
Room.type = ROOM

function Room.new(pos, dimensions, hitbox, blueprint, sprites)
	local room = setmetatable({}, Room)

	-- atributos que variam
	room.pos = pos -- posição da sala na array de salas
	room.dimensions = dimensions -- largura e altura da sala
	room.hitbox = hitbox -- pontos superior esquerdo (p1) e inferior direito (p2) da sala
	room.center = midpoint(hitbox.p1, hitbox.p2) -- ponto central da sala
	room.color = blueprint.color -- cor da sala
	room.sprites = sprites -- os sprites da sala em camadas
	-- atributos fixos na instanciação
	room.explored = false -- se algum jogador já entrou na sala ou não
	room.destructibles = {} -- lista de objetos destrutíveis da sala
	room.items = {} -- lista de itens dropados na sala
	room.enemies = {} -- lista de inimigos na sala
	room.playersInRoom = Set.new() -- lista de jogadores na sala

	return room
end

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
end

function Room:visit(player)
	if self.playersInRoom:has(player.id) then
		return
	end

	self.playersInRoom:add(player.id, player)
	activeRooms:add(makeKey(self.pos.x, self.pos.y), self)
end

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

-- instancia uma entidade e a insere na lista correspondente da sala
function Room:spawn(entity, pos)
	local constructor = CONSTRUCTORS[entity.type][entity.name]
	local real_pos = addVec(pos, self.center)
	if entity.type == ENEMY then
		table.insert(self.enemies, constructor(real_pos))
	elseif entity.type == DESTRUCTIBLE then
		table.insert(self.destructibles, constructor(real_pos, self))
	end
end

----------------------------------------
-- Funções Globais
----------------------------------------
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

function createInitialRooms()
	-- cria a sala inicial do jogo e suas vizinhas
	newRoom({ x = 0, y = 0 }, Room.stdDim)
	rooms[0][0]:setExplored()
end

-- calcula as posições dos pontos superior esquerdo e inferior direito da sala
-- nas coordenadas de mundo
function calculateRoomLimits(r)
	local p1 = {
		x = r.pos.x * Room.stdDim.width - 265,
		y = r.pos.y * Room.stdDim.height - 260,
	}
	local p2 = {
		x = p1.x + r.dimensions.width,
		y = p1.y + r.dimensions.height,
	}
	return { p1 = p1, p2 = p2 }
end

-- cria uma key única baseada nas coordenadas da sala
function makeKey(x, y)
	return tostring(x) .. "," .. tostring(y)
end

return Room
