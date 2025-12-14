----------------------------------------
-- Importações
----------------------------------------
require("modules.utils.utils")
require("modules.utils.vec")
require("modules.systems.shaders")
require("modules.entities.player")
require("modules.utils.types")
require("modules.engine.collision")
require("table")

----------------------------------------
-- Classe Item
----------------------------------------

---@class Item
---@field object any
---@field pos Vec
---@field room Room
---@field vel Vec
---@field collected boolean
---@field autoPick boolean
---@field gravity number
---@field floorY number
---@field idleTimer number
---@field shine boolean
---@field hb Hitbox
---@field canPick boolean
---@field image table
---@field applyImpulse function
---@field setCollected function

Item = {}
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
	local item = setmetatable({}, Item)

	item.object = object -- objeto associado ao item (arma, recurso, etc)
	item.pos = pos -- posição do item no mundo
	item.room = room -- sala onde o item está
	item.vel = vec(0, 0) -- velocidade para física simples
	item.collected = false -- flag de coleta
	item.autoPick = autoPick -- se o item é coletado automaticamente ou manualmente
	item.gravity = 600 -- força da gravidade
	item.floorY = item.pos.y + (floorY or 0) -- posição onde irá parar de cair
	item.idleTimer = 0 -- timer para oscilar enquanto parado
	item.shine = false -- se está brilhando
	local hbRadius = autoPick and 30 or 60
	item.hb = hitbox(Circle.new(hbRadius), pos) -- hitbox do item
	item.canPick = false -- se o item pode ser coletado (true após terminar de cair)

	local sprite_path = pngPathFormat({ "assets", "sprites", "items", object.name })
	item.image = love.graphics.newImage(sprite_path)
	item.image:setFilter("nearest", "nearest")

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
	local newPos = {}
	-- aplica velocidade (se houver)
	if not nullVec(self.vel) then
		self.vel.y = self.vel.y + self.gravity * dt
		newPos.y = self.pos.y + self.vel.y * dt
		newPos.x = self.pos.x + self.vel.x * dt

		-- colisão simples com o chão
		if newPos.y > self.floorY and self.vel.y > 0 then
			newPos.y = self.floorY
			self.vel.y = 0
			self.vel.x = 0
			self.canPick = true
		end
	else
		-- fica oscilando levemente enquanto no chão
		newPos.y = self.floorY - 5 * (math.sin(self.idleTimer * 5) + 1)
		self.idleTimer = self.idleTimer + dt
	end
	if not newPos.x then
		newPos.x = self.pos.x
	end
	self:setPos(newPos)
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
	local index = tableIndexOf(self.room.items, self)
	if index then
		table.remove(self.room.items, index)
	end
end

----------------------------------------
-- Física simples
----------------------------------------

---@param impulseVec Vec
-- aplica um impulso que movimenta o item em uma determinada direção
function Item:applyImpulse(impulseVec)
	-- Aplica um impulso instantâneo ao item
	self.vel = addVec(self.vel, impulseVec)
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

	item:applyImpulse(impuselVec)
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
