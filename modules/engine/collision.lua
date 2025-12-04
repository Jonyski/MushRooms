----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.utils.utils")

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

function hitbox(shape, pos)
	return { shape = shape, pos = pos }
end

function copyHitbox(hb, pos)
	local shape = copyShape(hb.shape)
	return {
		shape = shape,
		pos = pos or vec(hb.pos.x, hb.pos.y)
	}
end

function copyShape(shape)
	if shape.shape == CIRCLE then
		return Circle.new(shape.radius)
	elseif shape.shape == RECTANGLE then
		return Rectangle.new(shape.width, shape.height)
	elseif shape.shape == LINE then
		return Line.new(shape.angle, shape.length)
	end
	return nil
end

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------
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
			return checkRectLineCollision(hb2.hb1)
		elseif hb2.shape.shape == LINE then
			return checkLineLineCollision(hb1, hb2)
		end
	end

	return nil
end

function pointOnLine(point, line)
	local d1 = dist(point, line.pos)
	local d2 = dist(point, polarToVec(line.shape.angle, line.shape.length) + line.pos)
	local leniency = 0.01
	if d1 + d2 < line.shape.length + leniency and d1 + d2 > line.shape.length - leniency then
		return true
	end
	return false
end

function checkCircleCircleCollision(circle1, circle2)
	return dist(circle1.pos, circle2.pos) <= circle1.shape.radius + circle2.shape.radius
end

function checkCircleRectCollision(circle, rect)
	local rectCenter = vec(rect.pos.x + rect.shape.halfW, rect.pos.y + rect.shape.halfH)
	local dist = vec(math.abs(circle.pos.x - rectCenter.x), math.abs(circle.pos.y - rectCenter.y))
	if dist.x > (rect.shape.halfW + circle.shape.radius) or dist.y > (rect.shape.halfH + circle.shape.radius) then
		return false
	end
	if dist.x <= rect.shape.halfW or dist.y <= rect.shape.halfH then
		return true
	end
	local cornerDist = (dist.x - rect.shape.halfW) ^ 2 + (dist.y - rect.shape.halfH) ^ 2
	return cornerDist <= circle.shape.radius ^ 2
end

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

CollisionManager = {}
CollisionManager.__index = CollisionManager
CollisionManager.type = COLLISION_MANAGER

function CollisionManager.init()
	local cm = setmetatable({}, CollisionManager)
	-- cada tabela associa uma entidade a uma hitbox
	cm.items = {}
	cm.enemies = {}
	cm.players = {}
	cm.enemyAttacks = {}
	cm.playerAttacks = {}
	cm.destructibles = {}
	-- otimização: manter uma cópia das salas ativas
	-- para minimizar o número de colisões checadas
	cm.activeRoomsCopy = Set.new()
	cm.activeRoomsCopy:copy(activeRooms)

	return cm
end

function CollisionManager:fetchHitboxesByRoom(room)
	-- pegando hitboxes de inimigos
	for _, enemy in pairs(room.enemies) do
		self.enemies[enemy] = enemy.hb
	end
	-- pegando hitboxes de destrutiveis
	for _, destr in pairs(room.destructibles) do
		self.destructibles[destr] = destr.hb
	end
	-- pegando hitboxes de itens
	for _, item in pairs(room.items) do
		self.items[item] = item.hb
	end
end

function CollisionManager:clearHitboxesByRoom(room)
	-- removendo hitboxes de inimigos
	for _, enemy in pairs(room.enemies) do
		self.enemies[enemy] = nil
	end
	-- removendo hitboxes de destrutiveis
	for _, destr in pairs(room.destructibles) do
		self.destructibles[destr] = nil
	end
	-- removendo hitboxes de itens
	for _, item in pairs(room.items) do
		self.items[item] = nil
	end
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
	for k, room in self.activeRoomsCopy:iter() do
		self:fetchHitboxesByRoom(room)
	end
	-- eliminando hitboxes de ataques não mais ativos
	for atkEvent, _ in pairs(self.playerAttacks) do
		if not atkEvent.active then
			self.playerAttacks[atkEvent] = nil
		end
	end
	
	for atkEvent, _ in pairs(self.enemyAttacks) do
		if not atkEvent.active then
			self.enemyAttacks[atkEvent] = nil
		end
	end
end

function CollisionManager:handleCollisions()
	----------- PLAYER / ITEM -----------
	for item, itemhb in pairs(self.items) do
		if item.collected then
			self.items[item] = nil
			goto nextitem
		end
		for player, playerhb in pairs(self.players) do
			local hit = checkCollision(itemhb, playerhb)
			if hit then
				-- ao colidir -> tenta coletar item
				player:tryCollectItem(item)
			end
			item:setShine(hit)
		end
		::nextitem::
	end

	--------- INIMIGO / ATAQUE ----------
	for enemy, enemyhb in pairs(self.enemies) do
		for attack, attackhb in pairs(self.playerAttacks) do
			local hit = checkCollision(enemyhb, attackhb)
			if hit then
				-- ao colidir -> dano no inimigo
				enemy:takeDamage(attack.dmg)
			end
		end
	end

	--------- INIMIGO / PLAYER ----------
	for enemy, enemyhb in pairs(self.enemies) do
		for player, playerhb in pairs(self.players) do
			local hit = checkCollision(enemyhb, playerhb)
			if hit and player.invulnerableTimer <= 0 then
				-- TODO: Implementar efeitos de colisão do player com inimigos
				player.invulnerableTimer = 1.0
				-- ao colidir -> dano no player
				print("ui")
			end
		end
	end

	--------- ATAQUE / PLAYER ----------
	for player, playerhb in pairs(self.players) do
		for attack, attackhb in pairs(self.enemyAttacks) do
			-- pula se o ataque já tiver acertado esse jogador
			if attack.targetsDamaged[player] then
				goto nextattackplayer
			end
			
			if attack.active and checkCollision(playerhb, attackhb) then
				attack.targetsDamaged[player] = true
				attack.piercesLeft = attack.piercesLeft - 1

				-- conta que o projétil atingiu, mas só aplica o efeito se o jogador não estiver invulnerável
				if player.invulnerableTimer > 0 then
					goto nextplayer
				end

				player.invulnerableTimer = 1.0
				attack:onHitFunc(player)
				-- goto nextplayer
			end
			::nextattackplayer::
		end
		::nextplayer::
	end

	------- PLAYER / DESTRUTIVEL --------
	for destr, destrhb in pairs(self.destructibles) do
		for player, playerhb in pairs(self.players) do
			local hit = checkCollision(destrhb, playerhb)
			if hit then
				-- ao colidir -> destrói objeto
				destr:damage(math.huge)
			end
		end
	end

	------- ATAQUE / DESTRUTIVEL --------
	for destr, destrhb in pairs(self.destructibles) do
		for attack, attackhb in pairs(self.playerAttacks) do
			local hit = checkCollision(destrhb, attackhb)
			if hit then
				-- ao colidir -> destrói objeto
				destr:damage(math.huge)
			end
		end
	end
end
