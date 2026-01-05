----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.utils")
require("modules.utils.vec")

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

--- tipos de hitbox
SOLID = "solid"
GAS = "gas"
TRIGGER = "trigger"

---@class Hitbox
---@field shape Shape
---@field pos Vec
---@field group CollisionGroup
---@field role? CollisionRole

---@alias CircleHitbox {pos: Vec, shape: Circle}
---@alias RectHitbox {pos: Vec, shape: Rectangle}
---@alias LineHitbox {pos: Vec, shape: Line}
---@alias HitboxData {hb: Hitbox, owner: Entity, role: CollisionRole, group: CollisionGroup}
---@alias CollisionRole
---| "solid"
---| "gas"
---| "trigger"
---@alias CollisionGroup
---| "player"
---| "enemy"
---| "item"
---| "npc"
---| "playerAttack"
---| "enemyAttack"
---| "destructible"
---| "undefined"

---@param shape Shape
---@param pos Vec
---@param group? string
---@param role? CollisionRole
---@return Hitbox
-- cria uma `Hitbox`, estrutura com forma e posição
function hitbox(shape, pos, group, role)
	return { 
		shape = shape,
		pos = pos, 
		group = group or "undefined",
		role = role or GAS, 
	}
end

---@param hb Hitbox
---@param pos? Vec
---@return Hitbox
-- retorna uma cópia de `hb` podendo ou não distinguir sua posição
-- da hitbox original com o uso do parâmetro `pos`
function copyHitbox(hb, pos)
	local shape = copyShape(hb.shape)
	return {
		shape = shape,
		pos = pos or vec(hb.pos.x, hb.pos.y),
		role = hb.role,
		group = hb.group,
	}
end

---@param shape Shape | Circle | Rectangle | Line
---@return Shape
-- retorna uma cópia do formato passado como argumento
function copyShape(shape)
	if shape.shape == CIRCLE then
		return Circle.new(shape.radius)
	elseif shape.shape == RECTANGLE then
		return Rectangle.new(shape.width, shape.height)
	else
		return Line.new(shape.angle, shape.length)
	end
end

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

---@param hb1 Hitbox
---@param hb2 Hitbox
---@return boolean
-- recebe duas hitboxes, retorna true se elas se tocam
function checkCollision(hb1, hb2)
	if hb1.shape.shape == CIRCLE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleCircleCollision(hb1, hb2)
		elseif hb2.shape.shape == RECTANGLE then
			return checkCircleRectCollision(hb1, hb2)
		elseif hb2.shape.shape == LINE then
			return checkCircleLineCollision(hb1, hb2)
		end
	elseif hb1.shape.shape == RECTANGLE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleRectCollision(hb2, hb1)
		elseif hb2.shape.shape == RECTANGLE then
			return checkRectRectCollision(hb1, hb2)
		elseif hb2.shape.shape == LINE then
			return checkRectLineCollision(hb1, hb2)
		end
	elseif hb1.shape.shape == LINE then
		if hb2.shape.shape == CIRCLE then
			return checkCircleLineCollision(hb2, hb1)
		elseif hb2.shape.shape == RECTANGLE then
			return checkRectLineCollision(hb2, hb1)
		elseif hb2.shape.shape == LINE then
			return checkLineLineCollision(hb1, hb2)
		end
	end

	return false
end

---@param point Vec
---@param line {pos: Vec, shape: Line} Hitbox em formato de linha
---@return boolean
-- verifica se a linha `line` contém o ponto `point`
function pointOnLine(point, line)
	local d1 = dist(point, line.pos)
	local d2 = dist(point, polarToVec(line.shape.angle, line.shape.length) + line.pos)
	local leniency = 0.01
	if d1 + d2 < line.shape.length + leniency and d1 + d2 > line.shape.length - leniency then
		return true
	end
	return false
end

---@param circle1 CircleHitbox
---@param circle2 CircleHitbox
---@return boolean
-- checa se dois círculos estão colidindo
function checkCircleCircleCollision(circle1, circle2)
	return dist(circle1.pos, circle2.pos) <= circle1.shape.radius + circle2.shape.radius
end

function checkCircleRectCollision(circle, rect)
	local dist = vec(math.abs(circle.pos.x - rect.pos.x), math.abs(circle.pos.y - rect.pos.y))
	if dist.x > (rect.shape.halfW + circle.shape.radius) or dist.y > (rect.shape.halfH + circle.shape.radius) then
		return false
	end
	if dist.x <= rect.shape.halfW or dist.y <= rect.shape.halfH then
		return true
	end
	local cornerDist = (dist.x - rect.shape.halfW) ^ 2 + (dist.y - rect.shape.halfH) ^ 2
	return cornerDist <= circle.shape.radius ^ 2
end

---@param circle CircleHitbox
---@param line LineHitbox
---@return boolean
-- checa se um círculo e uma linha estão colidindo
function checkCircleLineCollision(circle, line)
	local p1 = line.pos
	local p2 = addVec(p1, polarToVec(line.shape.angle, line.shape.length))
	if dist(p1, circle.pos) < circle.shape.radius or dist(p2, circle.pos) < circle.shape.radius then
		return true
	end
	local dot = dotProd(subVec(circle.pos, p1), subVec(p2, p1))
	local closestX = p1.x + (dot * (p2.x - p1.x))
	local closestY = p1.y + (dot * (p2.y - p1.y))
	if not pointOnLine(vec(closestX, closestY), line) then
		return false
	end
	local distX = closestX - circle.pos.x
	local distY = closestY - circle.pos.y
	local dist = distX ^ 2 + distY ^ 2
	if dist <= circle.shape.radius ^ 2 then
		return true
	end
	return false
end

---@param rect1 RectHitbox
---@param rect2 RectHitbox
---@return boolean
-- checa se dois retângulos estão colidindo
function checkRectRectCollision(rect1, rect2)
	if
		rect1.pos.x + rect1.shape.width >= rect2.pos.x
		and rect1.pos.x <= rect2.pos.x + rect2.shape.width
		and rect1.pos.y + rect1.shape.height >= rect2.pos.y
		and rect1.pos.y <= rect2.pos.y + rect2.shape.height
	then
		return true
	end
	return false
end

---@param rect RectHitbox
---@param line LineHitbox
---@return boolean
-- checa se um retângulo e uma linha estão colidindo
function checkRectLineCollision(rect, line)
	local leftSide = hitbox(Line.new(math.pi * 3 / 2, rect.shape.height), rect.pos)
	local upSide = hitbox(Line.new(0, rect.shape.width), rect.pos)
	local rightSide =
		hitbox(Line.new(math.pi * 3 / 2, rect.shape.height), addVec(rect.pos, scaleVec(vec(1, 0), rect.shape.width)))
	local downSide = hitbox(Line.new(0, rect.shape.width), addVec(rect.pos, scaleVec(vec(0, 1), rect.shape.height)))
	local leftHit = checkLineLineCollision(line, leftSide)
	local upHit = checkLineLineCollision(line, upSide)
	local rightHit = checkLineLineCollision(line, rightSide)
	local downHit = checkLineLineCollision(line, downSide)
	if leftHit or upHit or rightHit or downHit then
		return true
	end
	return false
end

---@param line1 LineHitbox
---@param line2 LineHitbox
---@return boolean
-- checa se duas linhas estão colidindo
function checkLineLineCollision(line1, line2)
	local p1 = line1.pos
	local p2 = addVec(p1, polarToVec(line1.shape.angle, line1.shape.length))
	local p3 = line2.pos
	local p4 = addVec(p3, polarToVec(line2.shape.angle, line2.shape.length))

	local a = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x))
		/ ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
	local b = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x))
		/ ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
	if a >= 0 and a <= 1 and b >= 0 and b <= 1 then
		return true
	end
	return false
end

----------------------------------------
-- Classe Collision Manager
----------------------------------------

---@class CollisionManager
---@field registry table<Entity, HitboxData>
---@field byRole table<CollisionRole, table<Entity, HitboxData>>
---@field byGroup table<CollisionGroup, table<Entity, HitboxData>>
---@field roomsDirty boolean
---@field activeTriggerPairs table<string, TriggerPair>
---@field currentTriggerPairs table<string, TriggerPair>
---@field activeRoomsCopy Set<Room>
---@field collisionRules CollisionRule[]
---@alias TriggerPair {a: Entity, b: Entity, rule: CollisionRule}
---@alias CollisionRule {a: CollisionGroup, b: CollisionGroup, onEnter: string, onExit?: string}

CollisionManager = {}
CollisionManager.__index = CollisionManager
CollisionManager.type = COLLISION_MANAGER

function CollisionManager.init()
	local cm = setmetatable({}, CollisionManager)

	cm.registry = {} -- tabela principal de registro de hitboxes
	cm.byRole = {} -- tabela de indexação por 'role' (solid, gas, trigger)
	cm.byGroup = {} -- tabela de indexação por 'group' (player, enemy, item, etc)
	cm.roomsDirty = false -- flag para indicar se as listas de hitboxes precisam ser atualizadas
	cm.activeTriggerPairs = {} -- pares de colisão 'trigger' ativos na última atualização
	cm.currentTriggerPairs = {} -- pares de colisão 'trigger' detectados na atualização atual

	-- otimização: manter uma cópia das salas ativas
	-- para minimizar o número de colisões checadas
	cm.activeRoomsCopy = Set.new()
	cm.activeRoomsCopy:copy(activeRooms)

	return cm
end

-- atualiza o gerenciador de colisões
function CollisionManager:update(dt)
	self:updateHitboxListsIfNeeded()
	self:handleCollisions()
end

---@param room Room
-- adiciona as hitboxes das entidades em `room` à respectiva
-- lista do `CollisionManager`
function CollisionManager:fetchHitboxesByRoom(room)
	-- pegando hitboxes de inimigos
	for _, enemy in pairs(room.enemies) do
		for _, attack in pairs(enemy.atk.events) do
			self:register(attack)
		end
		self:register(enemy)
	end
	-- pegando hitboxes de destrutiveis
	for _, destr in pairs(room.destructibles) do
		if destr.state == INTACT then
			self:register(destr)
		end
	end
	-- pegando hitboxes de itens
	for _, item in pairs(room.items) do
		self:register(item)
	end
	-- pegando hitboxes de npcs
	for _, npc in pairs(room.npcs) do
		self:register(npc)
	end
end

---@param room Room
-- remove as hitboxes das entidades em `room` das suas
-- respectivas listas do `CollisionManager`
function CollisionManager:clearHitboxesByRoom(room)
	-- removendo hitboxes de inimigos
	for _, enemy in pairs(room.enemies) do
		for _, attack in pairs(enemy.atk.events) do
			self:unregister(attack)
		end
		self:unregister(enemy)
	end
	-- removendo hitboxes de destrutiveis
	for _, destr in pairs(room.destructibles) do
		self:unregister(destr)
	end
	-- removendo hitboxes de itens
	for _, item in pairs(room.items) do
		self:unregister(item)
	end
	-- removendo hitboxes de npcs
	for _, npc in pairs(room.npcs) do
		self:unregister(npc)
	end
end

-- verifica se as listas de hitboxes precisam ser atualizadas
function CollisionManager:updateHitboxListsIfNeeded()
  if not self.roomsDirty then 
		return 
	end

  self:updateHitboxLists()
  self.roomsDirty = false
end

-- atualiza as listas de hitboxes para conter hitboxes apenas de salas ativas
function CollisionManager:updateHitboxLists()
	-- eliminando as hitboxes de uma sala recém desativada
	for k, room in self.activeRoomsCopy:iter() do
		local present = activeRooms:has(k)
		if not present then
			self:clearHitboxesByRoom(room)
		end
	end
	-- atualizando nossa cópia das salas ativas
	self.activeRoomsCopy:copy(activeRooms)
	-- pegando as hitboxes de todas as salas ativas
	for _, room in self.activeRoomsCopy:iter() do
		self:fetchHitboxesByRoom(room)
	end
end

---@param entity Entity
-- registra a hitbox da entidade `entity` nas listas do `CollisionManager`
function CollisionManager:register(entity)
  if not entity.hb then 
		return 
	end

	local role = entity.hb.role or GAS
	local group = entity.hb.group

	---@type HitboxData
  local data = {
    hb = entity.hb,
    owner = entity,
    role = role,
    group = group
  }

	print("Registering " .. entity.name .. " to CollisionManager as " .. role .. " in group " .. group)

  -- registry: fonte da verdade
  self.registry[entity] = data

  -- indexação por role
  self.byRole[role] = self.byRole[role] or {}
  self.byRole[role][entity] = data

  -- indexação por grupo
  if group then
    self.byGroup[group] = self.byGroup[group] or {}
    self.byGroup[group][entity] = data
  end
end

---@param entity Entity
-- remove a hitbox da entidade `entity` das listas do `CollisionManager`
function CollisionManager:unregister(entity)
  local data = self.registry[entity]
  if not data then return end

	print("Unregistering " .. entity.name .. " from CollisionManager")

	local group = data.group
	local role = data.role

  self.byRole[role][entity] = nil
  self.registry[entity] = nil

  if group and self.byGroup[group] then
    self.byGroup[group][entity] = nil
  end

end

function CollisionManager:handleCollisions()
	self.currentTriggerPairs = {}

	for _, rule in ipairs(self.collisionRules) do
		self:processRule(rule)
	end

	self:processTriggerExit()
	self.activeTriggerPairs = self.currentTriggerPairs
end

--- @param rule CollisionRule
-- processa uma regra de colisão específica
function CollisionManager:processRule(rule)
	local groupA = self.byGroup[rule.a]
	local groupB = self.byGroup[rule.b]

	if not groupA or not groupB then 
		return
	end

	local handler = self[rule.onEnter]
	if not handler then
		 return 
	end

	for entA, dataA in pairs(groupA) do
		for entB, dataB in pairs(groupB) do
			if checkCollision(dataA.hb, dataB.hb) then
				
				-- registrando pares de triggers ativos
				if dataA.role == TRIGGER or dataB.role == TRIGGER then
					local key = pairKey(entA, entB)

					self.currentTriggerPairs[key] = {
						a = entA,
						b = entB,
						rule = rule
					}
				end

				handler(self, entA, entB)
			end
		end
	end
end

function CollisionManager:processTriggerExit()
	for key, pair in pairs(self.activeTriggerPairs) do
		-- se está na lista de colisões ativas, mas não na atual,
		-- significa que a colisão terminou
		if not self.currentTriggerPairs[key] then
			local handler = self[pair.rule.onExit]

			if handler then
				print("Collision exit between " .. pair.a.name .. " and " .. pair.b.name)
				handler(self, pair.a, pair.b)

			end
		end
	end
end

---@param entity Entity
---@param nextPos Vec
---@return Vec correctedPos
-- resolve colisões sólidas para a `entity` ao tentar se mover para `nextPos`
function CollisionManager:resolveSolidCollisions(entity, nextPos)
	local pos = vec(entity.pos.x, entity.pos.y)

	-- tentativa de movimento em X
	if nextPos.x ~= pos.x then
		local testPosX = vec(nextPos.x, pos.y)
		local testHbX = copyHitbox(entity.hb, testPosX)

		if not self:collidesWithSolid(entity, testHbX) then
			pos.x = nextPos.x
		else
			pos.x = self:findClosestNonCollidingPos(entity, pos, nextPos, "x")
			entity.vel.x = 0
		end
	end

	-- tentativa de movimento em Y
	if nextPos.y ~= pos.y then
		local testPosY = vec(pos.x, nextPos.y)
		local testHbY = copyHitbox(entity.hb, testPosY)

		if not self:collidesWithSolid(entity, testHbY) then
			pos.y = nextPos.y
		else
			pos.y = self:findClosestNonCollidingPos(entity, pos, nextPos, "y")
			entity.vel.y = 0
		end
	end

	return pos
end

---@param entity Entity
---@param testHb Hitbox
---@return boolean, Entity|nil
-- checa se a `testHb` colide com alguma hitbox sólida registrada
function CollisionManager:collidesWithSolid(entity, testHb)
	local solids = self.byRole[SOLID]

	if not solids then
		return false
	end

	for other, data in pairs(solids) do
		if other ~= entity then
			local otherHb = data.hb
			
			if otherHb and checkCollision(testHb, otherHb) then
				return true, other
			end
		end
	end

	return false
end

---@param entity Entity
---@param startPos Vec
---@param endPos Vec
---@param axis "x" | "y"
-- encontra a posição mais próxima de `endPos` em que `entity`
-- não colide com hitboxes sólidas, movendo-se ao longo do eixo `axis
function CollisionManager:findClosestNonCollidingPos(entity, startPos, endPos, axis)
	local low = 0
	local high = 1
	local best = startPos[axis]

	for _ = 1, 8 do
		local mid = (low + high) / 2

		local testPos = vec(startPos.x, startPos.y)
		testPos[axis] = startPos[axis] + (endPos[axis] - startPos[axis]) * mid

		local testHb = copyHitbox(entity.hb, testPos)

		if self:collidesWithSolid(entity, testHb) then
			high = mid
		else
			best = testPos[axis]
			low = mid
		end
	end

	return best
end


----------------------------------------
-- Regras de Colisão
----------------------------------------

CollisionManager.collisionRules = {
	{
		a = PLAYER,
		b = ITEM,
		onEnter = "onPlayerItem"
	},
	{
		a = ENEMY,
		b = ATTACK_PLAYER,
		onEnter = "onEnemyHitByPlayerAttack"
	},
	{
		a = ENEMY,
		b = PLAYER,
		onEnter = "onEnemyPlayer"
	},
	{
		a = PLAYER,
		b = ATTACK_ENEMY,
		onEnter = "onPlayerHitByEnemyAttack"
	},
	{
		a = PLAYER,
		b = NPC,
		onEnter = "onPlayerNpc",
		onExit = "onPlayerNpcExit"
	},
	{
		a = PLAYER,
		b = DESTRUCTIBLE,
		onEnter = "onPlayerDestructible"
	},
	{
		a = ATTACK_PLAYER,
		b = DESTRUCTIBLE,
		onEnter = "onPlayerDestructible"
	},
}

---@param player Player
---@param item Item
-- trata a colisão entre um `player` e um `item`
function CollisionManager:onPlayerItem(player, item)
	player:tryCollectItem(item)
	item:setShine(true)
end

---@param enemy Enemy
---@param attack AtkEvent
-- trata a colisão entre um `enemy` e um `player`
function CollisionManager:onEnemyHitByPlayerAttack(enemy, attack)
	if not attack.active then return end
	if attack.targetsDamaged[enemy] then return end

	attack.targetsDamaged[enemy] = true
	attack.piercesLeft = attack.piercesLeft - 1

	if enemy.invulnerableTimer > 0 then return end

	enemy.invulnerableTimer = 0.5
	enemy:takeDamage(attack.dmg)
end

---@param enemy Enemy
---@param player Player
-- trata a colisão entre um `enemy` e um `player`
function CollisionManager:onEnemyPlayer(enemy, player)
	if player.invulnerableTimer > 0 then return end

	print(player.name .. " hit by enemy " .. enemy.name)
	player.invulnerableTimer = 1.0
end

---@param player Player
---@param attack AtkEvent
-- trata a colisão entre um `player` e um `attack` inimigo
function CollisionManager:onPlayerHitByEnemyAttack(player, attack)
	if not attack.active then return end
	if attack.targetsDamaged[player] then return end

	attack.targetsDamaged[player] = true
	attack.piercesLeft = attack.piercesLeft - 1

	if player.invulnerableTimer > 0 then return end

	player.invulnerableTimer = 1.0
	attack:onHit(player)
end

---@param player Player
---@param npc Npc
-- trata a colisão entre um `player` e um `npc`
function CollisionManager:onPlayerNpc(player, npc)
	player.interactiveObj = npc
	npc.reachable = true
end

---@param player Player
---@param npc Npc
-- trata o fim da colisão entre um `player` e um `npc`
function CollisionManager:onPlayerNpcExit(player, npc)
	if player.interactiveObj == npc then
		player.interactiveObj = nil
	end

	npc.reachable = false
end

---@param destructible Destructible
-- trata a colisão entre um `player` ou um `attack` do player e um `destructible`
function CollisionManager:onPlayerDestructible(_, destructible)
	destructible:damage(math.huge)
end