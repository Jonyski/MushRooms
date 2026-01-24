----------------------------------------
-- Classe UIScene
----------------------------------------

UIScene = {}
UIScene.__index = UIScene
UIScene.type = UI_SCENE

function UIScene.new(sceneType)
    local uiscene = setmetatable({}, UIScene)
    uiscene.subtype = sceneType
    uiscene.active = false
    uiscene.layers = {}
end

function UIScene:addElement(element, layer, pos)
    self.layers[layer][pos.y][pos.x] = element
    return self
end

function UIScene:removeElement(layer, pos)
    self.layers[layer][pos.y][pos.x] = nil
    return self
end

function UIScene:update(dt)
    for _, layer in pairs(self.layers) do
        for _, row in pairs(layer) do
            for _, el in pairs(row) do
                el:update(dt)
            end
        end
    end
end

function UIScene:draw()
    for _, layer in pairs(self.layers) do
        for _, row in pairs(layer) do
            for _, el in pairs(row) do
                el:draw()
            end
        end
    end
end
