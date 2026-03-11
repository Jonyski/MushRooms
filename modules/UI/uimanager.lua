----------------------------------------
-- Classe UIManager
----------------------------------------

UIManager = {}
UIManager.__index = UIManager
UIManager.type = UI_MANAGER

function UIManager.new(player)
    local uimanager = setmetatable({}, UIManager)
    uimanager.player = player
    uimanager.canvas = love.graphics.newCanvas(1280, 720)
    uimanager.canvasSize = size(1280, 720)
    uimanager.canvasPos = vec(0, 0)
    uimanager.scenes = {}
    uimanager.activeScene = nil
    return uimanager
end

function UIManager:setParentCanvas(canvas, canvasPos)
    self.parentCanvas = canvas
    self.parentCanvasPos = canvasPos
    local parentW = canvas:getWidth()
    local parentH = canvas:getHeight()
    self.canvas = love.graphics.newCanvas(parentW, parentH)
    self.canvasSize = size(parentW, parentH)
end

function UIManager:addScene(scene)
    self.scenes[scene.subtype] = scene
    return self
end

function UIManager:activateScene(sceneType)
    self.scenes[sceneType].active = true
    self.activeScene = sceneType
end

function UIManager:deactivateScene(sceneType)
    self.scenes[sceneType].active = false
    -- !TODO: implementar um stack de cenas ativas para UIs sobrepostas
    self.activeScene = nil
end

function UIManager:isSceneActive(sceneType)
    return self.scenes[sceneType].active
end

function UIManager:toggleScene(sceneType)
    self.scenes[sceneType].active = not self.scenes[sceneType].active
end

function UIManager:deactivateAllScenes()
    for _, scene in pairs(self.scenes) do
        scene.active = false
    end
    self.activeScene = nil
end

function UIManager:update(dt)
    for _, scene in pairs(self.scenes) do
        if scene.active then
            scene:update(dt)
        end
    end
end

function UIManager:draw(camera)
    love.graphics.setCanvas(self.canvas)
    love.graphics.clear(0.0, 0.0, 0.0, 0.0)
    for _, scene in pairs(self.scenes) do
        if scene.active then
            scene:draw()
        end
    end
    if camera then
        love.graphics.setCanvas(camera.canvas)
    else
        love.graphics.setCanvas()
    end

    love.graphics.push()
    love.graphics.translate(window.offset.x, window.offset.y)
    love.graphics.scale(window.scale)

    love.graphics.draw(self.canvas, self.canvasPos.x, self.canvasPos.y)

    love.graphics.pop()
end

function UIManager:keypressed(key, isrepeat)
    if self.activeScene then
        self.scenes[self.activeScene]:keypressed(key, isrepeat)
    end
end
