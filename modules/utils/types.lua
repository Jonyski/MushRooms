----------------------------------------
-- Enum dos tipos do jogo
----------------------------------------
---@alias Type string
PLAYER = "player"
ENEMY = "enemy"
NPC = "npc"
ROOM = "room"
WEAPON = "weapon"
RESOURCE = "resource"
ITEM = "item"
DESTRUCTIBLE = "destructible"
INTERACTIVE = "interactive"
COLOR = "color"
LOOT = "loot"
ATTACK = "attack"
PLAYER_ATTACK = "player attack"
ENEMY_ATTACK = "enemy attack"
ATTACK_EVENT = "attack event"
BLUEPRINT = "blueprint"
SPAWNPOINT = "spawnpoint"
SPAWN_DATA = "spawn data"
COLLISION_MANAGER = "collision manager"
DIALOGUE = "dialogue"
INVENTORY = "inventory"

----------------------------------------
-- Registro das entidades do jogo
----------------------------------------

---@class EntityReg
---@field type Type
---@field name string

---@param type Type
---@param name string
---@return EntityReg
function registerEntity(type, name)
	return { type = type, name = name }
end

--------------- INIMIGOS ---------------
SPIDER_DUCK = registerEntity(ENEMY, "Spider Duck")
NUCLEAR_CAT = registerEntity(ENEMY, "Nuclear Cat")

----------------- NPCs -----------------
GLOB = registerEntity(NPC, "Glob")

---------------- ARMAS -----------------
KATANA = registerEntity(WEAPON, "Katana")
SLING_SHOT = registerEntity(WEAPON, "Sling Shot")

------------- DESTRUTÍVEIS -------------
JAR = registerEntity(DESTRUCTIBLE, "jar")
BARREL = registerEntity(DESTRUCTIBLE, "barrel")

----------------- ITEM -----------------
COIN = registerEntity(ITEM, "coin")

------------ RESOURCES --------------
WOOD = registerEntity(RESOURCE, "wood")
STONE = registerEntity(RESOURCE, "stone")
BREAD = registerEntity(RESOURCE, "bread")
BONE = registerEntity(RESOURCE, "bone")
FEATHER = registerEntity(RESOURCE, "feather")
IRON = registerEntity(RESOURCE, "iron")
GOLD = registerEntity(RESOURCE, "gold")

----------------- ROOM -----------------
