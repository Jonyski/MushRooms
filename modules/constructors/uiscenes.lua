----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uiscene")
require("modules.UI.elements.button")
require("modules.UI.elements.image")
require("modules.constructors.uielements")

----------------------------------------
-- Cenas Globais
----------------------------------------

function initMenuScene()
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

    return menuScene
end

----------------------------------------
-- Cenas de Player
----------------------------------------

function newResourceInventoryScene(canvasSize)
    local invScene = UIScene.new(UI_INVENTORY_SCENE)
    local canvasCenter = vec(canvasSize.width / 2, canvasSize.height / 2)

    -- ANIMAÇÕES
    local animSettings = {}
    animSettings[IDLE] = newAnimSetting(1, size(32, 32), 1, true, 1)
    animSettings[SELECTED] = newAnimSetting(1, size(32, 32), 1, true, 1)
    local bgAnimSettings = {}
    bgAnimSettings[IDLE] = newAnimSetting(1, size(128, 128), 1, true, 1)

    -- BACKGROUND
    local pos = subVec(canvasCenter, vec(256, 256))
    print("X -> " .. pos.x .. " Y -> " .. pos.y)
    local invBg = UIImageElem.new("resource inventory bg", canvasCenter, size(768, 768))
    invBg:addAnimations(bgAnimSettings)
    invScene:addElement(invBg, BG_LAYER_1, vec(1, 1))

    -- SLOTS
    local leftMargin = canvasCenter.x - 300
    local topMargin = canvasCenter.y
    for row = 0, 2 do
        for col = 0, 4 do
            local posX = leftMargin + col * 120
            local posY = topMargin + row * 108
            local slot = UIImageElem.new("resource slot", vec(posX, posY), size(96, 96))
            slot:addAnimations(animSettings)
            invScene:addElement(slot, VISUAL_LAYER_1, vec(col + 1, row + 1))
        end
    end

    -- MÉTODOS AUXILIARES
    function invScene:addResourceEl(resource, inventory, canvasSize)
        local invLength = inventory:length(RESOURCE)
        local col = math.fmod(invLength - 1, 5)
        local row = math.floor((invLength - 1) / 5)
        local resourceEl = newResourceItemElement(resource.name, invLength, canvasSize)
        self:addElement(resourceEl, ELEM_LAYER, vec(col + 1, row + 1))
    end

    return invScene
end
