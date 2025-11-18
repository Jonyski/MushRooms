----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.entities.enemy")
require("modules.entities.destructibles")

----------------------------------------
-- Mapa de construtores
----------------------------------------

-- útil para a lógica de spawn, pois só descobrimos o tipo
-- e o nome da entidade em tempo de execução
-- Indexado pelo tipo da entidade e então pelo nome dela
CONSTRUCTORS = {}

CONSTRUCTORS[ENEMY] = {
	[SPIDER_DUCK.name] = newSpiderDuck,
	[NUCLEAR_CAT.name] = newNuclearCat,
}

CONSTRUCTORS[DESTRUCTIBLE] = {
	[BARREL.name] = newBarrel,
	[JAR.name] = newJar,
}
