----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.movements")
require("modules.utils.easing")

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Gato Nuclear
function newNuclearCat(spawnPos, room)
	local movementFunc = avoidTarget(300, range(150, 180), Easing.outQuad)
	local attackFunc = Enemy.shootAttack
	local hitbox = hitbox(Rectangle.new(40, 70), spawnPos)
	local enemy = Enemy.new(NUCLEAR_CAT.name, 30, spawnPos, 180, movementFunc, attackFunc, hitbox, room)
	local idleAnimSettings = newAnimSetting(6, { width = 32, height = 32 }, 0.15, true, 1)
	local dyingAnimSettings = newAnimSetting(6, { width = 32, height = 32 }, 0.001, false, 1)
	enemy:addAnimations(idleAnimSettings, dyingAnimSettings)
	enemy:setProjectileAtk()
	enemy.easingFunc = Easing.outQuad
	return enemy
end

---@param spawnPos Vec
---@param room Room
---@return Enemy
-- cria um inimigo do tipo Pato Aranha
function newSpiderDuck(spawnPos, room)
	local movementFunc = dashTowardsTarget(Easing.outQuad)
	local attackFunc = Enemy.simpleAttack
	local hitbox = hitbox(Circle.new(25), spawnPos)
	local enemy = Enemy.new(SPIDER_DUCK.name, 20, spawnPos, 180, movementFunc, attackFunc, hitbox, room)
	local idleAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.4, true, 1)
	local dyingAnimSettings = newAnimSetting(4, { width = 32, height = 32 }, 0.001, false, 1)
	enemy:addAnimations(idleAnimSettings, dyingAnimSettings)
	enemy.easingFunc = Easing.outQuad
	return enemy
end
