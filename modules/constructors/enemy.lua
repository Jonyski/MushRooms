----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.attacks")
require("modules.constructors.movements")
require("modules.utils.easing")

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Gato Nuclear
function newNuclearCat(spawnPos, room)
	local movementFunc = avoidTargetMovement(250, 0.75, 1.25, math.rad(30), Easing.inOutQuad)
	local attack = newPebbleShotAttack(false, 2.5, 5.0, 500, sineMovement(math.rad(60)))
	local hb = hitbox(Rectangle.new(40, 70))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(1, 65, 4)
	local enemy = Enemy.new(NUCLEAR_CAT.name, 30, spawnPos, physics, movementFunc, attack, hbs, room)
	local idleAnimSettings = newAnimSetting(6, { width = 32, height = 32 }, 0.15, true, 1)
	local dyingAnimSettings = newAnimSetting(6, { width = 32, height = 32 }, 0.001, false, 1)
	enemy:addAnimations(idleAnimSettings, dyingAnimSettings)
	return enemy
end

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Pato Aranha
function newSpiderDuck(spawnPos, room)
	local movementFunc = dashToTargetMovement(0.8, 1.5, math.rad(15), Easing.outQuad)
	local attackFunc = newPebbleShotAttack(false, 3, 3, 400, zigZagMovement(1, math.rad(35)))
	local hb = hitbox(Circle.new(25))
	local hbs = hitboxes({ hb })
	local physics = physicsSettings(0.8, 50, 5)
	local enemy = Enemy.new(SPIDER_DUCK.name, 20, spawnPos, physics, movementFunc, attackFunc, hbs, room)
	local idleAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.4, true, 1)
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.001, false, 1)
	enemy:addAnimations(idleAnimSettings, dyingAnimSettings)
	return enemy
end
