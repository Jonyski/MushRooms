----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.utils")

----------------------------------------
-- Funções locais
----------------------------------------
local function floorAnchor(y)
	return { floor = y }
end

----------------------------------------
-- Variáveis e Enums
----------------------------------------
FLOOR = "floor"

-- Observação: os valores aqui são relativos ao centro do sprite
-- No futuro, outros anchors podem ser adicionados (head, hand, etc)
ANCHORS = {
	-- Items
	katana = floorAnchor(11),
	sling_shot = floorAnchor(8),
	coin = floorAnchor(8),

	-- Destrutíveis
	barrel = floorAnchor(10),
	jar = floorAnchor(4),

	-- Inimigos
	spider_duck = floorAnchor(14),
	nuclear_cat = floorAnchor(16),

	-- Jogadores
	mush = floorAnchor(10),
	musho = floorAnchor(10),
	roomy = floorAnchor(11),
	shroom = floorAnchor(13),
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
