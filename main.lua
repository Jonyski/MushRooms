----------------------------------------
-- Importações de Módulos
----------------------------------------
require "table"
require "modules/room"
require "modules/game"
require "modules/player"
require "modules/camera"
require "modules/animation"
require "modules/enemy"

----------------------------------------
-- Variáveis Globais
----------------------------------------
window = {}
sec_timer = {}
----------------------------------------
-- Callbacks
----------------------------------------
function love.keypressed(key, scancode, isrepeat)
	-- esc closes the game
	if key == "escape" then
		love.event.quit()
	end
	-- n adds a new player to the game
	if key == "n" then
		newPlayer()
	end

	for _, p in pairs(players) do
		p:checkMovement(key, "press")
	end
end

function love.keyreleased(key, scancode, isrepeat)
	for _, p in pairs(players) do
		p:checkMovement(key, "release")
	end
end

function love.resize(w, h)
	window.width = w
	window.height = h
	window.cx = w / 2
	window.cy = h / 2
	for i, c in pairs(cameras) do
		cameras[i] = nil
	end
	for i = 1, #players do
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
	sec_timer = {prev = 0, curr = 0}
	createInitialRooms()
	newPlayer()

	-- métodos de estado do love
	love.window.setMode(window.width, window.height, {resizable = true})
end

----------------------------------------
-- Atualização
----------------------------------------
function love.update(dt)
	for _, p in pairs(players) do
		p:move(dt)
		p.animations[p.state]:update(dt)
		p:updateState()
	end
	for _, c in pairs(cameras) do
		c:updatePosition()
	end

	sec_timer.curr = sec_timer.curr + dt
	if sec_timer.curr - sec_timer.prev >= 1 then
		sec_timer.prev = sec_timer.prev + 1
		if math.random() < 0.2 then
			newEnemy(NUCLEAR_CAT, {x = 800, y = 800})
		elseif math.random() < 0.2 then
			newEnemy(SPIDER_DUCK, {x = 800, y = 800})
		end
	end
	for _, e in pairs(enemies) do
		e:move(dt)
	end

end

----------------------------------------
-- Renderização
----------------------------------------
function love.draw()
	for i, c in pairs(cameras) do
		love.graphics.setCanvas(c.canvas)
		love.graphics.clear(0.0, 0.0, 0.0, 1.0)
		renderRooms(i)
		renderPlayers(i)
		renderEnemies(i)
		love.graphics.setCanvas()
		love.graphics.draw(c.canvas, c.canvasPos.x, c.canvasPos.y)
	end
end