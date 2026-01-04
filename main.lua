----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.dialogue")
require("modules.engine.animation")
require("modules.engine.camera")
require("modules.engine.collision")
require("modules.engine.renderization")
require("modules.entities.destructible")
require("modules.entities.enemy")
require("modules.entities.item")
require("modules.entities.player")
require("modules.entities.room")
require("modules.entities.weapon")
require("modules.systems.dialogue")
require("modules.UI.menu")
require("modules.UI.ui")
require("table")

local appleCake = require("libs.applecake")(true)
appleCake = require("libs.applecake")()
appleCake.setBuffer(true)
appleCake.beginSession()

----------------------------------------
-- Variáveis Globais
----------------------------------------

window = { scale = 1, offset = vec(0, 0) }
gameCtx = MENU_CTX
local updateProfile
local drawProfile

----------------------------------------
-- Callbacks
----------------------------------------

function love.keypressed(key, scancode, isrepeat)
	-- esc fecha o jogo
	if key == "escape" then
		quitGame()
	end

	-- repassa para o handler do LUIS
	luis.keypressed(key, scancode, isrepeat)

	-- n adiciona um player ao jogo
	if key == "n" then
		newPlayer()
	end
	-- q faz a câmera 1 tremer (teste)
	if key == "c" then
		cameras[1]:shake(20, 1)
	end
	-- z dá zoom na câmera 1 (teste)
	if key == "z" then
		cameras[1].targetZoom = 2
	end

	if key == "1" then
		spawnItem(newKatana(), players[1].pos, players[1].room, false, getAnchor(players[1], FLOOR), vec(0, 0))
	end

	if key == "2" then
		spawnItem(newSlingShot(), players[1].pos, players[1].room, false, getAnchor(players[1], FLOOR), vec(0, 0))
	end

	if not isrepeat then
		for _, p in pairs(players) do
			p:checkAction1(key)
			p:checkAction2(key)
		end
	end
end

function love.keyreleased(key, scancode)
	luis.keyreleased(key, scancode)
	if key == "z" then
		cameras[1].targetZoom = cameras[1].startingZoom
	end
end

function love.mousepressed(x, y, button, istouch, presses)
	luis.mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	luis.mousereleased(x, y, button, istouch, presses)
end

function love.resize(w, h)
	local sx = w / window.width
	local sy = h / window.height
	window.scale = math.max(sx, sy)
	local offsetX = (w - window.width * window.scale) / 2
	local offsetY = (h - window.height * window.scale) / 2
	window.offset = vec(offsetX, offsetY)

	for i, _ in pairs(cameras) do
		cameras[i] = nil
	end
	for _, p in pairs(players) do
		newCamera(p)
	end

	luis.updateScale()
end

----------------------------------------
-- Inicialização
----------------------------------------

function love.load()
	-- muda o filtro padrão para eliminar o efeito de blur
	love.graphics.setDefaultFilter("nearest", "nearest")

	-- carregando a biblioteca de UI
	setupLUIS()

	-- definindo a seed de aleatoriedade
	math.randomseed(os.time())

	-- definindo a fonte padrão do jogo
	-- não sei qual fonte é melhor
	tempFont = love.graphics.newFont("assets/fonts/Tiny5-Regular.ttf", 16)
	-- tempFont = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 12)

	-- definindo as dimensões iniciais do jogo
	window.width = 1280
	window.height = 720
	window.cx = window.width / 2 -- centro no eixo x
	window.cy = window.height / 2 -- centro no eixo y

	-- criando e carregando o menu do jogo
	initMenu()

	-- métodos de estado do love
	love.window.setMode(window.width, window.height, { resizable = true, vsync = true, msaa = 0 })
end

----------------------------------------
-- Atualização
----------------------------------------

function love.update(dt)
	-- iniciando o profiling da função de update
	updateProfile = appleCake.profileFunc(nil, updateProfile)

	-- pulando o update de gameplay enquanto está no menu
	if gameCtx == MENU_CTX then
		goto uiupdate
	end

	DialogueManager:update(dt)
	---------- Jogadores ----------
	for _, p in pairs(players) do
		p:update(dt)
	end
	----------- Cameras -----------
	for _, c in pairs(cameras) do
		c:updatePosition(dt)
	end
	------------ Salas ------------
	for _, r in activeRooms:iter() do
		r:update(dt)
	end
	----------- Colisões ----------
	collisionManager:updateHitboxLists()
	collisionManager:handleCollisions()

	-------------- UI -------------
	::uiupdate::
	luis.update(dt)

	-- encerrando o profiling
	updateProfile:stop()
end

----------------------------------------
-- Renderização
----------------------------------------

function love.draw()
	-- iniciando o profiling da função de update
	drawProfile = appleCake.profileFunc(nil, drawProfile)

	for _, c in pairs(cameras) do
		c:draw()
	end
	luis.draw()

	-- encerrando o profiling
	drawProfile:stop()
	appleCake.flush()
end

----------------------------------------
-- Encerramento
----------------------------------------

function love.quit()
	appleCake.endSession()
end
