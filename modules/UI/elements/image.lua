----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")

----------------------------------------
-- Classe UIImageElem
----------------------------------------

UIImageElem = setmetatable({}, { __index = UIElement })
UIImageElem.__index = UIImageElem

function UIImageElem.new(name, pos, size, hitboxes)
	local img = setmetatable({}, UIImageElem)
	img:init(name, UI_IMAGE_ELEM, pos, size, hitboxes)
	return img
end
