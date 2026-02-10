----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uimanager")
require("modules.UI.uiscene")
require("modules.UI.elements.button")
require("modules.UI.elements.image")

function initGlobalUIManager()
	local globalManager = UIManager.new()
	local menuScene = UIScene.new(UI_MENU_SCENE)

	-- ELEMENTOS
	local menuBg = UIImageElem.new("menu bg", vec(640, 360), size(1280, 720))
	local startBtn = UIButtonElem.new("menu play btn", vec(280, 400), size(120, 120), nil, function()
		print("Botão clicado -> Start")
		startGame()
	end)
	local settingsBtn = UIButtonElem.new("menu opt btn", vec(620, 400), size(120, 120), nil, function()
		print("Botão clicado -> Settings")
	end)
	local quitBtn = UIButtonElem.new("menu quit btn", vec(960, 400), size(120, 120), nil, function()
		print("Botão clicado -> Quit")
		quitGame()
	end)

	-- ANIMAÇÕES
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
	animSettings[SELECTED] = newAnimSetting(4, size(32, 32), 0.08, true, 4)
	startBtn:addAnimations(animSettings)
	settingsBtn:addAnimations(animSettings)
	quitBtn:addAnimations(animSettings)
	local bgAnimSettings = {}
	bgAnimSettings[IDLE] = newAnimSetting(1, size(320, 180), 1, true, 1)
	menuBg:addAnimations(bgAnimSettings)

	-- SETUP DA CENA
	menuScene:addElement(menuBg, BG_LAYER_1, vec(1, 1))
	menuScene:addElement(startBtn, ELEM_LAYER, vec(1, 1))
	menuScene:addElement(settingsBtn, ELEM_LAYER, vec(2, 1))
	menuScene:addElement(quitBtn, ELEM_LAYER, vec(3, 1))

	globalManager:addScene(menuScene)
	globalManager:activateScene(UI_MENU_SCENE)

	return globalManager
end
