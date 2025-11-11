----------------------------------------
-- Variável Global
----------------------------------------
ANCHORS = {
	-- Observação: os valores aqui são relativos ao centro do sprite

	-- Items
	["katana"] = { floor = 11 },
	["slingshot"] = { floor = 8 },
	["coin"] = { floor = 8 },

	-- Destrutíveis
	["barrel"] = { floor = 10 },
	["jar"] = { floor = 4 },

	-- Inimigos
	["spider_duck"] = { floor = 14 },
	["nuclear_cat"] = { floor = 16 },

	-- Jogadores
	["mush"] = { floor = 10 },
	["musho"] = { floor = 10 },
  ["roomy"] = { floor = 11 },
  ["shroom"] = { floor = 13 },
}

----------------------------------------
-- Funções Globais
----------------------------------------
function getAnchor(obj, anchorType, scale)
	scale = scale or 3

	-- pega do próprio objeto se já tiver sido calculado
	if obj.anchors and obj.anchors[anchorType] then
		return obj.anchors[anchorType]
	end

	local key = obj.type or obj.name
  key = pathlizeName(string.lower(key))
	local anchor = ANCHORS[key][anchorType]

	if anchor then
		obj.anchors = obj.anchors or {}
		obj.anchors[anchorType] = anchor * scale

		return obj.anchors[anchorType]
	end

	-- fallback padrão
	return 0
end