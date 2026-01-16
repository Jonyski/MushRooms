----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.interactive")

function newTurtle(spawnPos, room)
	local physics = physicsSettings(2, 800, 0.6)
	local defaulthb = { hitbox(Circle.new(20)) }
	local solidhb = { hitbox(Circle.new(20)) }
	local triggerhb = { hitbox(Circle.new(100)) }
	local hbs = hitboxes(defaulthb, solidhb, triggerhb)
	-- ao interagir com a tartaruga, você chuta ela para longe
	local onInteract = function(turtle, player)
		local forceDir = normalize(subVec(turtle.pos, player.pos))
		local forceVec = scaleVec(forceDir, 60000)
		applyForce(turtle, forceVec)
		turtle.state = MOVING
		print("Ao tartaruguínfinito e alémmm")
	end
	local update = function(turtle, dt)
		applyPhysics(turtle, dt)
		if lenVec(turtle.vel) < 20 then
			turtle.vel = vec(0, 0)
		end
		if nullVec(turtle.vel) then
			turtle.state = IDLE
		end
	end
	local turtle = Interactive.new("turtle", spawnPos, hbs, room, physics, onInteract, update)
	local animSettings = {}
	animSettings[IDLE] = newAnimSetting(2, { width = 32, height = 32 }, 0.2, true, 1)
	animSettings[MOVING] = newAnimSetting(8, { width = 32, height = 32 }, 0.08, true, 1)
	turtle:addAnimations(animSettings)
end
