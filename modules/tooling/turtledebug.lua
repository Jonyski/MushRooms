----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.interactive")
require("modules.constructors.interactives")
require("modules.utils.types")

----------------------------------------
-- Funções de debug
----------------------------------------

function _turtleDebugHandler(numberKey)
	local rPressed = love.keyboard.isDown("t")
	local numTurtles = tonumber(numberKey)
	if not rPressed or not numTurtles or numTurtles > 6 or numTurtles < 1 then
		return false
	end
	local room = players[1].room
	local centerPos = players[1].pos
	local angleStep = 2 * math.pi / numTurtles
	for i = 1, numTurtles do
		local posOffset = scaleVec(rotateVec(vec(0, -1), angleStep * (i - 1)), 100)
		spawnPosition = addVec(centerPos, posOffset)
		newTurtle(spawnPosition, room)
	end
	collisionManager.roomsDirty = true
	return true
end
