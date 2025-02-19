----------------------------------------
-- Importações de Módulos
----------------------------------------
require "table"
require "modules/player"
require "modules/room"
require "modules/camera"

----------------------------------------
-- Variáveis Globais
----------------------------------------
window = {}

----------------------------------------
-- Callbacks
----------------------------------------
function love.keypressed(key, scancode, isrepeat)
	for _, p in pairs(players) do
		p:checkMovement(key, "press")
	end
	-- esc closes the game
	if key == "escape" then
		love.event.quit()
	end
	-- n adds a new player to the game
	if key == "n" then
		newPlayer()
	end

end

function love.keyreleased(key, scancode, isrepeat)
	for _, p in pairs(players) do
		p:checkMovement(key, "release")
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
	newPlayer()
	newCamera()
	createInitialRooms()

	-- love's state-setting methods
	love.window.setMode(window.width, window.height)
end

----------------------------------------
-- Atualização
----------------------------------------
function love.update(dt)
	for _, p in pairs(players) do
		p:move(dt)
	end
	for _, c in pairs(cameras) do
		c:updatePosition()
	end
end

----------------------------------------
-- Renderização
----------------------------------------
function love.draw()
	love.graphics.clear(0.2, 0.2, 0.4, 1.0)
	-- salas
	for i = rooms.minIndex, rooms.maxIndex do
		for j = rooms[i].minIndex, rooms[i].maxIndex do
			local r = rooms[i][j]
			love.graphics.setColor(r.color.r, r.color.g, r.color.b, r.color.a)
			local roomWorldPos = {x = r.pos.x * 400 + 5 + window.cx, y = r.pos.y * 400 + 5 + window.cy}
			local roomViewPos = {x = roomWorldPos.x - cameras[1].cx, y = roomWorldPos.y - cameras[1].cy}
			love.graphics.rectangle("fill", roomViewPos.x, roomViewPos.y, r.dimensions.width, r.dimensions.height, 5, 5)
		end
	end
	-- personagens
	for _, p in pairs(players) do
		pViewPos = {x = p.pos.x - cameras[1].cx + window.cx, y = p.pos.y - cameras[1].cy + window.cy}
		love.graphics.setColor(p.color.r, p.color.g, p.color.b, p.color.a)
		love.graphics.circle("fill", pViewPos.x, pViewPos.y, 20)
	end
end