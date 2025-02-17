----------------------------------------
-- Importações de Módulos
----------------------------------------
require"table"
require "modules/player"

----------------------------------------
-- Variáveis Globais
----------------------------------------
local window = {}
local players = {}
local player1 = {}

----------------------------------------
-- Callbacks
----------------------------------------
function love.keypressed(key, scancode, isrepeat)
	for _, p in pairs(players) do
		p:checkMovement(key, "press")
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
	player1 = Player.new(1,
	                     "mush",
	                     "assets/player1/",
	                     {x = window.width / 2, y = window.height / 2},
	                     {up = "w", left = "a", down = "s", right = "d", action = "space"})
	table.insert(players, player1)

	-- love's state-setting methods
	love.window.setMode(window.width, window.height)
end

----------------------------------------
-- Atualização
----------------------------------------
function love.update(dt)
	player1:move(dt)
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
		love.graphics.circle("fill", p.pos.x, p.pos.y, 10)
	end
end