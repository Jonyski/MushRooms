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

	----------------------------------------------------
	-- criação de objetos para debugging
	Destructible.new("jar", { x = 200, y = 0 }, rooms[0][0])
	Destructible.new("jar", { x = 300, y = 0 }, rooms[0][0])
	Destructible.new("jar", { x = 400, y = 0 }, rooms[0][0])
	Destructible.new("jar", { x = 200, y = -100 }, rooms[0][0])
	Destructible.new("jar", { x = 300, y = -100 }, rooms[0][0])
	Destructible.new("jar", { x = 400, y = -100 }, rooms[0][0])
	Destructible.new("barrel", { x = -400, y = 0 }, rooms[0][0])
	Destructible.new("barrel", { x = -200, y = 0 }, rooms[0][0], Loot.new(newSlingShot(), 1.0, range(1, 1), false))
	Destructible.new("barrel", { x = -300, y = 0 }, rooms[0][0], Loot.new(newKatana(), 1.0, range(1, 1), false))
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

	for _, r in activeRooms:iter() do
		-- atualiza destrutíveis
		for _, d in pairs(r.destructibles) do
			d:update(dt)
		end

		-- atualiza items
		for _, item in pairs(r.items) do
			item:update(dt)
		end
	end

	-- trecho de debug de inimigos ----------------------------
	local spawnEnemies = false

	sec_timer.curr = sec_timer.curr + dt
	if spawnEnemies and sec_timer.curr - sec_timer.prev >= 1 then
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
