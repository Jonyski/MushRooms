----------------------------------------
-- Classe UIScene
----------------------------------------

UIElement = {}
UIElement.__index = UIScene
UIElement.type = UI_SCENE

function UIElement.new(elementType, pos, size, hitboxes)
    local uielement = setmetatable({}, UIElement)
    uielement.subtype = elementType
    uielement.selected = false
    uielement.hb = hitboxes
    uielement.spriteSheets = {}
    uielement.animations = {}
end
