----------------------------------------
-- Importações de Módulos
----------------------------------------
require"table"
require "modules/player"

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
	newPlayer()

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
end

----------------------------------------
-- Renderização
----------------------------------------
function love.draw()
	love.graphics.clear(0.2, 0.2, 0.4, 1.0)
	for _, p in pairs(players) do
		love.graphics.setColor(p.color.r, p.color.g, p.color.b, p.color.a)
		love.graphics.circle("fill", p.pos.x, p.pos.y, 20)
	end
end