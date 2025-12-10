----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.entities.constructors.enemy")
require("modules.entities.constructors.player")
require("modules.entities.constructors.destructible")

----------------------------------------
-- Mapa de construtores
----------------------------------------

-- útil para a lógica de spawn, pois só descobrimos o tipo
-- e o nome da entidade em tempo de execução
-- Indexado pelo tipo da entidade e então pelo nome dela (exceto os players)
CONSTRUCTORS = {}

CONSTRUCTORS[PLAYER] = {
	initPlayer1,
	initPlayer2,
	initPlayer3,
	initPlayer4,
}

CONSTRUCTORS[ENEMY] = {
	[SPIDER_DUCK.name] = newSpiderDuck,
	[NUCLEAR_CAT.name] = newNuclearCat,
}

CONSTRUCTORS[DESTRUCTIBLE] = {
	[BARREL.name] = newBarrel,
	[JAR.name] = newJar,
}
