----------------------------------------
-- Enum dos tipos do jogo
----------------------------------------
PLAYER = "player"
ENEMY = "enemy"
ROOM = "room"
WEAPON = "weapon"
ITEM = "enemy"
DESTRUCTIBLE = "destructible"
COLOR = "color"
LOOT = "loot"
ATTACK = "attack"
ATTACK_EVENT = "attack event"
BLUEPRINT = "blueprint"
SPAWNPOINT = "spawnpoint"
SPAWN_DATA = "spawn data"

----------------------------------------
-- Registro das entidades do jogo
----------------------------------------

function registerEntity(type, name)
	return { type = type, name = name }
end

--------------- INIMIGOS ---------------
SPIDER_DUCK = registerEntity(ENEMY, "Spider Duck")
NUCLEAR_CAT = registerEntity(ENEMY, "Nuclear Cat")

---------------- ARMAS -----------------
KATANA = registerEntity(WEAPON, "Katana")
SLING_SHOT = registerEntity(WEAPON, "Sling Shot")

------------- DESTRUTÍVEIS -------------
JAR = registerEntity(DESTRUCTIBLE, "jar")
BARREL = registerEntity(DESTRUCTIBLE, "barrel")

----------------- ITEM -----------------
COIN = registerEntity(ITEM, "coin")
