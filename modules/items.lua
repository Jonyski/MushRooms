----------------------------------------
-- Importações
----------------------------------------
require("modules/utils")
require("modules/vec")
require("modules/shaders")
require("modules/player")
require("table")

----------------------------------------
-- Tabela de comportamentos por tipo de item
----------------------------------------
ITEM_BEHAVIORS = {
	["katana"] = function(player, item)
		local success = player:collectWeapon(newWeapon(KATANA))
    if success then
      player:equipWeapon(KATANA)
			return true
		else
			return false
    end
	end,

	["slingshot"] = function(player, item)
		local success = player:collectWeapon(newWeapon(SLING_SHOT))
    if success then
      player:equipWeapon(SLING_SHOT)
			return true
		else
			return false
    end
	end,

	["coin"] = function(player, item)
		print("moedinhaaa")

		return true
	end,
}

----------------------------------------
-- Classe Item
----------------------------------------
Item = {}
Item.__index = Item

function Item.new(typeName, pos, room, pickupType, floorY)
	local item = setmetatable({}, Item)

	item.type = typeName                     -- nome do item
	item.pos = { x = room.center.x + pos.x,  -- posição relativa ao centro da sala
               y = room.center.y + pos.y }
  item.room = room                         -- sala onde o item está
	item.vel = { x = 0, y = 0 }              -- velocidade para física simples
	item.radius = 50                         -- usado para colisão e dist()
	item.collected = false                   -- flag de coleta
	item.pickupType = pickupType or "auto"   -- "auto" (pego ao colidir) ou "manual" (pego ao apertar botão)
	item.gravity = 600                       -- força da gravidade
	item.floorY = item.pos.y + (floorY or 0) -- posição onde irá parar de cair
  item.idleTimer = 0                       -- timer para oscilar enquanto parado
	item.shine = false                       -- se está brilhando
  item.onCollect = nil                     -- callback chamado ao coletar item

	item.image = love.graphics.newImage("assets/sprites/items/" .. typeName .. ".png")
	item.image:setFilter("nearest", "nearest")

  -- associa comportamento ao coletar (se existir)
	if ITEM_BEHAVIORS[typeName] then
		item.onCollect = function(player)
			local sucess = ITEM_BEHAVIORS[typeName](player, item)
			return sucess
		end
	end

	table.insert(room.items, item)

	return item
end

----------------------------------------
-- Atualização
----------------------------------------
function Item:update(dt)
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
    self.pos.y = self.floorY - 5*(math.sin(self.idleTimer * 5) + 1)
    self.idleTimer = self.idleTimer + dt
  end
end

----------------------------------------
-- Renderização
----------------------------------------
function Item:draw(camera)
	if self.collected then return end

  local scale = 2.5
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

----------------------------------------
-- Lógica de coleta
----------------------------------------
function Item:checkPickup(players)
  -- não pode ser coletado enquanto está em movimento (e se já foi coletado)
	if self.collected or not nullVec(self.vel) then return end

	local anyPlayerNear = false

	for _, player in pairs(players) do
		local distance = dist(self.pos, player.pos)

		if distance < self.radius then
			anyPlayerNear = true

			if self.pickupType == "auto" then
				self:collect(player)
				return

			elseif self.pickupType == "manual" and love.keyboard.isDown(player.controls.act2) then
        self:collect(player)
        return

			end
		end
	end

	if anyPlayerNear and not self.shine then
		self.shine = true
	elseif not anyPlayerNear and self.shine then
		self.shine = false
	end
end


function Item:collect(player)
	local successfullColect = true
	
  if self.onCollect then
		successfullColect = self.onCollect(player, self)
	end
	
	if successfullColect then
		self.collected = true
		table.remove(self.room.items, tableIndexOf(self.room.items, self))
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
function newItem(typeName, pos, room, pickupType, floorY)
	return Item.new(typeName, pos, room, pickupType, floorY)
end

return Item