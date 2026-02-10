----------------------------------------
-- Classe UIScene
----------------------------------------

UIElement = {}
UIElement.__index = UIElement
UIElement.type = UI_ELEMENT

function UIElement:init(name, elementType, pos, size, hitboxes)
    self.name = name
    self.subtype = elementType
    self.pos = pos
    self.size = size
    self.hb = hitboxes
    self.state = IDLE
    self.selected = false
    self.spriteSheets = {}
    self.animations = {}
end

function UIElement:addAnimations(animSettings)
    for state, settings in pairs(animSettings) do
        local path = pngPathFormat({ "assets", "animations", "UI", self.name, state })
        addAnimation(self, path, state, settings)
    end
end

function UIElement:update(dt)
    self.animations[self.state]:update(dt)
end

function UIElement:select()
    self.selected = true
    self.state = SELECTED
end

function UIElement:deselect()
    self.selected = false
    self.animations[self.state]:reset()
    self.state = IDLE
end

function UIElement:draw(camera)
    local viewPos = self.pos
    if camera then
        viewPos = camera:viewPos(self.pos)
    end
    local anim = self.animations[self.state]
    local quad = anim.frames[anim.currFrame]
    local scale = self.size.width / anim.frameDim.width
    local offset = {
        x = anim.frameDim.width / 2,
        y = anim.frameDim.height / 2,
    }
    love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, scale, scale, offset.x, offset.y)
end
