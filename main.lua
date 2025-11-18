----------------------------------------
-- Importações de Módulos
----------------------------------------
require("table")
require("modules.entities.room")
require("modules.engine.renderization")
require("modules.entities.player")
require("modules.engine.camera")
require("modules.engine.animation")
require("modules.entities.enemy")
require("modules.entities.weapon")
require("modules.entities.destructibles")
require("modules.entities.items")

----------------------------------------
-- Variáveis Globais
----------------------------------------
window = {}
sec_timer = {}

----------------------------------------
-- Callbacks
----------------------------------------
function love.keypressed(key, scancode, isrepeat)
	-- esc fecha o jogo
	if key == "escape" then
		love.event.quit()
	end
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

	if not isrepeat then
		for _, p in pairs(players) do
			p:checkAction1(key)
			p:checkAction2(key)
		end
	end
end

function love.keyreleased(key)
	if key == "z" then
		cameras[1].targetZoom = 1
	end
end

function love.resize(w, h)
	window.width = w
	window.height = h
	window.cx = w / 2
	window.cy = h / 2
	for i, _ in pairs(cameras) do
		cameras[i] = nil
	end
	for _ = 1, #players do
		newCamera()
	end
end

----------------------------------------
-- Inicialização
----------------------------------------
function love.load()
	math.randomseed(os.time())
	window.width = 800
	window.height = 800
	window.cx = 400 -- centro no eixo x
	window.cy = 400 -- centro no eixo y
	sec_timer = { prev = 0, curr = 0 }
	createInitialRooms()
	newPlayer()

	-- métodos de estado do love
	love.window.setMode(window.width, window.height, { resizable = true })
end

----------------------------------------
-- Atualização
----------------------------------------
function love.update(dt)
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
end

----------------------------------------
-- Renderização
----------------------------------------
function love.draw()
	for _, c in pairs(cameras) do
		c:draw()
	end
end
