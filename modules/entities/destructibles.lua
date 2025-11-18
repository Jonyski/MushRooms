----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.animation")
require("modules.utils.utils")
require("modules.systems.loots")
require("modules.utils.types")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------

INTACT = "intact"
BREAKING = "breaking"
BROKEN = "broken"

----------------------------------------
-- Classe Destructible
----------------------------------------
Destructible = {}
Destructible.__index = Destructible
Destructible.type = DESTRUCTIBLE

function Destructible.new(name, pos, room, loot)
	local obj = setmetatable({}, Destructible)

	obj.name = name -- nome do objeto
	obj.pos = pos -- posição do destrutível no mundo
	obj.room = room -- sala a qual pertence
	obj.state = INTACT
	obj.health = 100 -- vida para ser destruído
	obj.spriteSheets = {}
	obj.animations = {}
	obj.loot = loot or LOOT_TABLE[name] or Loot.new() -- pode ser sobrescrito na criação

	obj:addAnimations()
	return obj
end

----------------------------------------
-- Animações
----------------------------------------
function Destructible:addAnimations()
	self:addAnimation(INTACT, 1, 1, true)
	self:addAnimation(BREAKING, 7, 0.05, false)
	self:addAnimation(BROKEN, 1, 1, true)
end

function Destructible:addAnimation(state, numFrames, frameDur, looping)
	local path = pngPathFormat({ "assets", "animations", "destructibles", self.name, state })
	local quadSize = { width = 64, height = 64 }
	local animation = newAnimation(path, numFrames, quadSize, frameDur, looping, 1, quadSize)
	self.animations[state] = animation
	self.spriteSheets[state] = love.graphics.newImage(path)
	self.spriteSheets[state]:setFilter("nearest", "nearest")
end

----------------------------------------
-- Lógica de dano e destruição
----------------------------------------
function Destructible:damage(amount)
	if self.state == BROKEN or self.state == BREAKING then
		return
	end

	self.health = self.health - amount
	if self.health <= 0 then
		self:breakApart()
	end
end

function Destructible:breakApart()
	self.state = BREAKING
	self:spawnLoot()
	local anim = self.animations[BREAKING]
	anim.onFinish = function()
		self.state = BROKEN
	end
end

----------------------------------------
-- Atualização
----------------------------------------
function Destructible:update(dt)
	self.animations[self.state]:update(dt)
end

----------------------------------------
-- Desenho
----------------------------------------
function Destructible:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local anim = self.animations[self.state]
	local quad = anim.frames[anim.currFrame]
	local offset = {
		x = anim.frameDim.width / 2,
		y = anim.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
end

function Destructible:spawnLoot()
	local loot = self.loot
	if not loot or loot.len == 0 then
		return
	end
	-- spawna aleatoriamente os drops possíveis na posição destrutível
	for i = 1, loot.len do
		local el = loot[i] -- elemento do loot
		if math.random() < el.chance then
			local amount = math.random(el.amountRange.min, el.amountRange.max)
			for j = 1, amount do
				local item_pos = { x = self.pos.x, y = self.pos.y }
				local item = newItem(el.object, item_pos, self.room, el.autoPick, math.random(-20, 20))
				item:applyImpulse(math.random(-100, 100), -math.random(150, 200))
			end
		end
	end
end

----------------------------------------
-- Construtores
----------------------------------------

function newBarrel(pos, room)
	local loot = Loot.new(newSlingShot(), 0.2, range(1, 1), false)
	loot:insert(newKatana(), 0.2, range(1, 1), false)
	loot:insert(COIN, 0.6, range(1, 5), true)
	return Destructible.new(BARREL.name, pos, room, loot)
end

function newJar(pos, room)
	local loot = Loot.new(COIN, 0.8, range(1, 3), true)
	return Destructible.new(JAR.name, pos, room, loot)
end

return Destructible
