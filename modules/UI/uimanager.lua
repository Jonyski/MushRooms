----------------------------------------
-- Classe UIManager
----------------------------------------

UIManager = {}
UIManager.__index = UIManager
UIManager.type = UI_MANAGER

function UIManager.new(player)
    local uimanager = setmetatable({}, UIManager)
    uimanager.player = player
    uimanager.scenes = {}
end

function UIManager:addScene(scene)
    self.scenes[scene.subtype] = scene
    return self
end

function UIManager:activateScene(sceneType)
    self.scenes[sceneType].active = true
end

function UIManager:deactivateScene(sceneType)
    self.scenes[sceneType].active = false
end

function UIManager:deactivateAllScenes()
    for _, scene in pairs(self.scenes) do
        scene.active = false
    end
end

function UIManager:update(dt)
    for _, scene in pairs(self.scenes) do
        scene:update(dt)
    end
end

function UIManager:draw()
    for _, scene in pairs(self.scenes) do
        scene:draw()
    end
end
