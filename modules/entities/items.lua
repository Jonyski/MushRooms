----------------------------------------
-- Importações
----------------------------------------
require("modules.utils.utils")
require("modules.utils.vec")
require("modules.systems.shaders")
require("modules.entities.player")
require("modules.utils.types")
require("table")

----------------------------------------
-- Classe Item
----------------------------------------
Item = {}
Item.__index = Item
Item.type = ITEM

function Item.new(object, pos, room, autoPick, floorY)
	local item = setmetatable({}, Item)

	item.object = object -- objeto associado ao item (arma, recurso, etc)
	item.pos = pos -- posição do item no mundo
	item.room = room -- sala onde o item está
	item.vel = { x = 0, y = 0 } -- velocidade para física simples
	item.radius = 50 -- usado para colisão e dist()
	item.collected = false -- flag de coleta
	item.autoPick = autoPick -- se o item é coletado automaticamente ou manualmente
	item.gravity = 600 -- força da gravidade
	item.floorY = item.pos.y + (floorY or 0) -- posição onde irá parar de cair
	item.idleTimer = 0 -- timer para oscilar enquanto parado
	item.shine = false -- se está brilhando

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
	self:updateShine()
end

function Item:move(dt)
	-- aplica velocidade (se houver)
	if not nullVec(self.vel) then
		self.vel.y = self.vel.y + self.gravity * dt
		self.pos.y = self.pos.y + self.vel.y * dt
		self.pos.x = self.pos.x + self.vel.x * dt

		-- colisão simples com o chão
		if self.pos.y >= self.floorY and self.vel.y > 0 then
			self.pos.y = self.floorY
			self.vel.y = 0
			self.vel.x = 0
		end
	else
		-- fica oscilando levemente enquanto no chão
		self.pos.y = self.floorY - 5 * (math.sin(self.idleTimer * 5) + 1)
		self.idleTimer = self.idleTimer + dt
	end
end

function Item:updateShine()
	local anyPlayerNearby = false
	for _, p in pairs(players) do
		local d = dist(self.pos, p.pos)
		if d <= self.radius then
			anyPlayerNearby = true
		end
	end
	self.shine = anyPlayerNearby
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
end

function Item:setCollected()
	self.collected = true
	table.remove(self.room.items, tableIndexOf(self.room.items, self))
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
function newItem(object, pos, room, pickupType, floorY)
	return Item.new(object, pos, room, pickupType, floorY)
end

return Item
