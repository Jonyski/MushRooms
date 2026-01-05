----------------------------------------
-- Importações
----------------------------------------
require("modules.engine.collision")
require("modules.entities.entity")
require("modules.entities.player")
require("modules.systems.shaders")
require("modules.systems.movement")
require("modules.utils.types")
require("modules.utils.utils")
require("modules.utils.vec")
require("table")

----------------------------------------
-- Classe Item
----------------------------------------

---@class Item: Entity
---@field object any
---@field collected boolean
---@field autoPick boolean
---@field gravity number
---@field floorY number
---@field idleTimer number
---@field shine boolean
---@field canPick boolean
---@field image table
---@field setCollected function

Item = setmetatable({}, { __index = Entity })
Item.__index = Item
Item.type = ITEM

---@param object any
---@param pos Vec
---@param room Room
---@param autoPick boolean
---@param floorY number
---@return Item
-- cria uma instância de `Item`
function Item.new(object, pos, room, autoPick, floorY)
	---@type Item
	local item = setmetatable({}, Item) ---@diagnostic disable-line

	local hbRadius = autoPick and 30 or 60
	local hitbox = hitbox(Circle.new(hbRadius), pos, ITEM)
	local physics = physicsSettings(0.5, 0, 6)
	item:init(object.name, pos, hitbox, room, physics)

	item.object = object -- objeto associado ao item (arma, recurso, etc)
	item.pos = pos -- posição do item no mundo
	item.room = room -- sala onde o item está
	item.collected = false -- flag de coleta
	item.autoPick = autoPick -- se o item é coletado automaticamente ou manualmente
	item.gravity = 1500 -- força da gravidade
	item.floorY = item.pos.y + (floorY or 0) -- posição onde irá parar de cair
	item.idleTimer = 0 -- timer para oscilar enquanto parado
	item.shine = false -- se está brilhando
	item.canPick = false -- se o item pode ser coletado (true após terminar de cair)

	local sprite_path = pngPathFormat({ "assets", "sprites", "items", object.name })
	item.image = love.graphics.newImage(sprite_path)
	item.image:setFilter("nearest", "nearest")

	collisionManager:register(item)
	table.insert(room.items, item)
	return item
end

----------------------------------------
-- Atualização
----------------------------------------

---@param dt number
-- atualiza o estado do `Item`
function Item:update(dt)
	self:move(dt)
end

---@param pos Vec
-- redefine a posição do `Item` e sua `hitbox`
function Item:setPos(pos)
	self.pos = pos
	self.hb.pos = pos
end

---@param dt number
-- movimenta o item, fazendo ele oscilar acima do chão ao colidir com ele
function Item:move(dt)
	-- antes de poder ser coletado, o item cai sob gravidade simples
	if not self.canPick then
		-- força para acelerar com gravidade constante (independente da massa)
		applyForce(self, vec(0, self.gravity * self.mass))
		applyPhysics(self, dt)
		-- colisão simples com o "chão" virtual em floorY
		if self.pos.y > self.floorY and self.vel.y > 0 then
			local clamped = vec(self.pos.x, self.floorY)
			setPos(self, clamped)
			self.vel.y = 0
			self.acc.y = 0
			self.canPick = true
		end
		return
	end

	-- após cair, oscila levemente acima do chão e mantém física horizontal
	applyPhysics(self, dt)
	self.idleTimer = self.idleTimer + dt
	local y = self.floorY - 5 * (math.sin(self.idleTimer * 5) + 1)
	setPos(self, vec(self.pos.x, y))
end

---@param value boolean
-- define se o item está brilhando (bordas brancas) ou não
function Item:setShine(value)
	self.shine = value
end

----------------------------------------
-- Renderização
----------------------------------------

---@param camera Camera
-- função de renderização do `Item` - desenha ele na
-- perspectiva da `camera` passada como argumento
function Item:draw(camera)
	if self.collected then
		return
	end

	local scale = 3
	local viewPos = camera:viewPos(self.pos)
	local offset = {
		x = self.image:getWidth() / 2,
		y = self.image:getHeight() / 2,
	}

	if self.shine then
		drawSpriteWithOutline(self.image, viewPos.x, viewPos.y, scale, offset)
	else
		love.graphics.draw(self.image, viewPos.x, viewPos.y, 0, scale, scale, offset.x, offset.y)
	end
end

-- marca o `Item` como tendo sido coletado
function Item:setCollected()
	self.collected = true
	collisionManager:unregister(self)
	local index = tableIndexOf(self.room.items, self)
	if index then
		table.remove(self.room.items, index)
	end
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@param object any
---@param pos Vec
---@param room any
---@param autoPick boolean
---@param floorY number
---@param impuselVec Vec
---@return Item
function spawnItem(object, pos, room, autoPick, floorY, impuselVec)
	local item = newItem(object, pos, room, autoPick, floorY)

	if nullVec(impuselVec) then
		item.canPick = true
		return item
	end

	applyImpulse(item, impuselVec)
	return item
end

---@param object any
---@param pos Vec
---@param room any
---@param autoPick boolean
---@param floorY number
---@return Item
function newItem(object, pos, room, autoPick, floorY)
	return Item.new(object, pos, room, autoPick, floorY)
end

return Item
