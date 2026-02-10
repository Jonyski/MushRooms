----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")

----------------------------------------
-- Classe UIButtonElem
----------------------------------------

UIButtonElem = setmetatable({}, { __index = UIElement })
UIButtonElem.__index = UIButtonElem

function UIButtonElem.new(name, pos, size, hitboxes, onClick)
	local btn = setmetatable({}, UIButtonElem)
	btn:init(name, UI_BUTTON_ELEM, pos, size, hitboxes)
	btn.onClick = onClick
	return btn
end
