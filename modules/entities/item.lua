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
Item = {}
Item.__index = Item
Item.type = ITEM

function Item.new(object, pos, room, autoPick, floorY)
	local item = setmetatable({}, Item)

	item.object = object                     -- objeto associado ao item (arma, recurso, etc)
	item.pos = pos                           -- posição do item no mundo
	item.room = room                         -- sala onde o item está
	item.vel = { x = 0, y = 0 }              -- velocidade para física simples
	item.collected = false                   -- flag de coleta
	item.autoPick = autoPick                 -- se o item é coletado automaticamente ou manualmente
	item.gravity = 600                       -- força da gravidade
	item.floorY = item.pos.y + (floorY or 0) -- posição onde irá parar de cair
	item.idleTimer = 0                       -- timer para oscilar enquanto parado
	item.shine = false                       -- se está brilhando
	local hbRadius = autoPick and 30 or 60
	item.hb = hitbox(Circle.new(hbRadius), pos) -- hitbox do item
	item.canPick = false                     -- se o item pode ser coletado (true após terminar de cair)

	local sprite_path = pngPathFormat({ "assets", "sprites", "items", object.name })
	item.image = love.graphics.newImage(sprite_path)
	item.image:setFilter("nearest", "nearest")

	table.insert(room.items, item)
	return item
end

----------------------------------------
-- Atualização
----------------------------------------
function Item:update(dt)
	self:move(dt)
end

function Item:setPos(pos)
	self.pos = pos
	self.hb.pos = pos
end

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

function Item:setShine(value)
	self.shine = value
end

----------------------------------------
-- Renderização
----------------------------------------
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

	---------- HITBOX DEBUG ----------
	if self.hb.shape.shape == CIRCLE then
		love.graphics.circle("line", viewPos.x, viewPos.y, self.hb.shape.radius)
	elseif self.hb.shape.shape == RECTANGLE then
		love.graphics.rectangle(
			"line",
			viewPos.x - self.hb.shape.halfW,
			viewPos.y - self.hb.shape.halfH,
			self.hb.shape.width,
			self.hb.shape.height
		)
	end
	----------------------------------
end

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
function Item:applyImpulse(dx, dy)
	-- Aplica um impulso instantâneo ao item
	self.vel.x = self.vel.x + dx
	self.vel.y = self.vel.y + dy
end

----------------------------------------
-- Funções Globais
----------------------------------------
function spawnItem(object, pos, room, autoPick, floorY, impuselVec)
	local item = newItem(object, pos, room, autoPick, floorY)

	if nullVec(impuselVec) then
		item.canPick = true
		return item
	end

	item:applyImpulse(impuselVec.x, impuselVec.y)
	return item
end

function newItem(object, pos, room, autoPick, floorY)
	return Item.new(object, pos, room, autoPick, floorY)
end

return Item
