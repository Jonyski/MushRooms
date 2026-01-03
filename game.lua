----------------------------------------
-- Importações de módulos
----------------------------------------
require("modules.engine.collision")
require("modules.entities.player")
require("modules.entities.room")

----------------------------------------
-- Enums
----------------------------------------
--- contexto atual do jogo
MENU_CTX = "Menu Context"
GAMEPLAY_CTX = "In-game Context"
QUITTING_CTX = "Quitting Context"

----------------------------------------
-- Funções globais
----------------------------------------

function startGame()
	createInitialRooms()
	collisionManager = CollisionManager.init()
	newPlayer()
	-- debug
	players[1]:collectWeapon(newSlingShot())
	players[1]:equipWeapon(SLING_SHOT.name)
	gameCtx = GAMEPLAY_CTX
end

function quitGame()
	gameCtx = QUITTING_CTX
	love.event.quit()
end
