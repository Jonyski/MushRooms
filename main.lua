----------------------------------------
-- Importações de Módulos
----------------------------------------
require("table")
require("modules/room")
require("modules/renderization")
require("modules/player")
require("modules/camera")
require("modules/animation")
require("modules/enemy")
require("modules/weapon")
require("modules/destructibles")

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
	window.width = 800
	window.height = 800
	window.cx = 400 -- centro no eixo x
	window.cy = 400 -- centro no eixo y
	sec_timer = { prev = 0, curr = 0 }
	createInitialRooms()
	newPlayer()

	-- bloco de teste de armas -------------------------
	players[1]:collectWeapon(newWeapon(SLING_SHOT))
	players[1]:collectWeapon(newWeapon(KATANA))
	players[1]:equipWeapon(SLING_SHOT)
	----------------------------------------------------
	-- criação de objetos para debugging
	newDestructible("barrel", { x = 100, y = 0 }, rooms[0][0])
	newDestructible("sign", { x = 200, y = 0 }, rooms[0][0])
	newDestructible("jar", { x = 300, y = 0 }, rooms[0][0])
	newDestructible("barrel", { x = 400, y = 0 }, rooms[0][0])
	newDestructible("barrel", { x = 600, y = 0 }, rooms[0][0])
	------------------------------------------------------

	-- métodos de estado do love
	love.window.setMode(window.width, window.height, { resizable = true })
end

----------------------------------------
-- Atualização
----------------------------------------
function love.update(dt)
	for _, p in pairs(players) do
		p:update(dt)
	end

	for _, c in pairs(cameras) do
		c:updatePosition(dt)
	end

	-- trecho de debug de inimigos ----------------------------
	sec_timer.curr = sec_timer.curr + dt
	if sec_timer.curr - sec_timer.prev >= 1 then
		sec_timer.prev = sec_timer.prev + 1
		local r = math.random()
		local randSpawnPos = {
			x = math.random(players[1].pos.x - 500, players[1].pos.x + 500),
			y = math.random(players[1].pos.y - 500, players[1].pos.y + 500),
		}
		if r < 0.2 then
			newEnemy(NUCLEAR_CAT, randSpawnPos)
		elseif r < 0.4 then
			newEnemy(SPIDER_DUCK, randSpawnPos)
		end
	end

	for _, e in pairs(enemies) do
		e:update(dt)
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
