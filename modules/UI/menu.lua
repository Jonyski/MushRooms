----------------------------------------
-- Importações de módulos
----------------------------------------
require("game")

----------------------------------------
-- Funções Globais
----------------------------------------

-- inicializa a interface do menu principal do jogo
function initMenu()
	luis.newLayer("main menu")
	luis.enableLayer("main menu")

	-- imagem de fundo
	local bg = luis.newIcon("assets/sprites/UI/menu/background.png", 80, 1, 1)
	bg.height = 45 * luis.gridSize
	luis.createElement("main menu", "Icon", bg)

	-- botão de play
	local startBtn = luis.newButton("", 6, 6, function()
		print("Botão clicado -> Start")
		startGame()
		luis.disableLayer("main menu")
	end, nil, 22, 24)
	local startBtnImg = love.graphics.newImage("assets/sprites/UI/menu/start_btn.png")
	startBtn:setDecorator("Slice9Decorator", startBtnImg, 0, 0, 0, 0)
	luis.createElement("main menu", "Button", startBtn)

	-- botão de configurações
	local optionsBtn = luis.newButton("", 6, 6, function()
		print("Botão clicado -> Options")
	end, nil, 22, 37)
	local optionsBtnImg = love.graphics.newImage("assets/sprites/UI/menu/options_btn.png")
	optionsBtn:setDecorator("Slice9Decorator", optionsBtnImg, 0, 0, 0, 0)
	luis.createElement("main menu", "Button", optionsBtn)

	-- botão de sair do jogo
	local quitBtn = luis.newButton("", 6, 6, function()
		print("Botão clicado -> Quit")
		quitGame()
	end, nil, 22, 50)
	local quitBtnImg = love.graphics.newImage("assets/sprites/UI/menu/quit_btn.png")
	quitBtn:setDecorator("Slice9Decorator", quitBtnImg, 0, 0, 0, 0)
	luis.createElement("main menu", "Button", quitBtn)
end
