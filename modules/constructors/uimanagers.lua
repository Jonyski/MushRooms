----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uimanager")
require("modules.UI.uiscene")
require("modules.UI.elements.button")
require("modules.UI.elements.image")
require("modules.constructors.uiscenes")

function initGlobalUIManager()
	local globalManager = UIManager.new()
	local menuScene = initMenuScene()
	globalManager:addScene(menuScene)
	globalManager:activateScene(UI_MENU_SCENE)
	return globalManager
end

function newPlayerUIManager(player)
	local playerManager = UIManager.new(player)
	local inventoryScene = newResourceInventoryScene(playerManager.canvasSize)
	playerManager:addScene(inventoryScene)

	return playerManager
end
