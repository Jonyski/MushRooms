----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.utils")

----------------------------------------
-- Variáveis e Enums
----------------------------------------
FLOOR = "floor"

ANCHORS = {
	-- Observação: os valores aqui são relativos ao centro do sprite
	-- No futuro, outros anchors podem ser adicionados (head, hand, etc)

	-- Items
	katana = { floor = 11 },
	sling_shot = { floor = 8 },
	coin = { floor = 8 },

	-- Destrutíveis
	barrel = { floor = 10 },
	jar = { floor = 4 },

	-- Inimigos
	spider_duck = { floor = 14 },
	nuclear_cat = { floor = 16 },
	-- Jogadores
	mush = { floor = 10 },
	musho = { floor = 10 },
  roomy = { floor = 11 },
  shroom = { floor = 13 },
}

----------------------------------------
-- Funções Globais
----------------------------------------
function getAnchor(obj, anchorType, scale)
	scale = scale or 3

	local key = obj.name or obj.object.name
  key = pathlizeName(string.lower(key))
	local anchor = ANCHORS[key][anchorType]

	if anchor then
		return anchor * scale
	end

	-- fallback padrão
	return 0
end