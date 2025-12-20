----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.movement")

----------------------------------------
-- Funções de Movimento
----------------------------------------
-- cada uma das funções abaixo é uma closure que retorna uma
-- função com contexto isolado capaz de mover uma entidade de
-- acordo com sua estratégia própria. As funções de movimento
-- em si possuem todas o mesmo protótipo. Portanto, a closure
-- serve para encapsular o estado do qual aquela função de
-- movimento específica depende, e recebe como argumento as
-- "configurações" que podem variar para aquele tipo de
-- movimento. Ou seja, estamos criando uma implementação do
-- padrão estratégia baseada em closures

---@param distanceThreshold number
---@return MovementFunc
-- se move constantemente na direção do alvo
function followTargetMovement(distanceThreshold)
	local threshold = distanceThreshold or 100

	return function(entity, dt)
		if not entity.target then
			return
		end

		local d = dist(entity.pos, entity.target.pos)
		if d > threshold then
			moveTowards(entity, entity.target.pos, dt)
		end
	end
end

---@param easingFunc easingFunc
---@return MovementFunc
-- movimento em "Pulos" na direção de um alvo com easing
function dashToTargetMovement(easingFunc)
	local moveTargetPos = nil
	local moveOriginPos = nil
	local timer = 0
	local duration = 0
	local cooldown = 0

	return function(entity, dt)
		if not entity.target then
			return
		end

		if cooldown > 0 then
			cooldown = cooldown - dt
			return
		end

		if not moveTargetPos or not moveOriginPos then
			local baseDir = normalize(subVec(entity.target.pos, entity.pos))
			local randAngle = math.rad(30) * (math.random() - 0.5) * 2
			local newDir = rotateVec(baseDir, randAngle)
			local travelDistance = math.random(110, 200)

			moveTargetPos = addVec(entity.pos, scaleVec(newDir, travelDistance))
			moveOriginPos = entity.pos
			timer = 0
			duration = travelDistance / entity.speed
		end

		timer = timer + dt
		local t = math.min(timer / duration, 1)
		local progress = easingFunc(t)

		local nextPos = addVec(moveOriginPos, scaleVec(subVec(moveTargetPos, moveOriginPos), progress))
		setPos(entity, nextPos)

		if t >= 1 then
			moveTargetPos = nil
			cooldown = 0.3 + math.random()
		end
	end
end

---@param safeDistance number
---@param travelDistanceRange range
---@param easingFunc easingFunc
---@return MovementFunc
-- cria uma lógica de movimento que mantém distância do alvo
function avoidTargetMovement(safeDistance, travelDistanceRange, easingFunc)
	local moveTargetPos = nil
	local moveOriginPos = nil
	local moveTimer = 0
	local moveDuration = 0
	local avoidCooldown = 0

	return function(entity, dt)
		if not entity.target then
			return
		end

		-- gerencia o cooldown interno de decisão
		if avoidCooldown > 0 then
			avoidCooldown = avoidCooldown - dt
		end

		local distTarget = dist(entity.pos, entity.target.pos)

		-- se não tem um destino e o alvo está muito perto, define nova rota de fuga
		if not moveOriginPos or not moveTargetPos and distTarget < safeDistance and avoidCooldown <= 0 then
			local baseDir = normalize(subVec(entity.target.pos, entity.pos))
			baseDir = scaleVec(baseDir, -1) -- direção oposta ao alvo
			local travelDist = math.random(travelDistanceRange.min, travelDistanceRange.max)

			moveTargetPos = addVec(entity.pos, scaleVec(baseDir, travelDist))
			moveOriginPos = entity.pos
			moveTimer = 0
			moveDuration = travelDist / entity.speed
		end

		if moveTargetPos then
			moveTimer = moveTimer + dt
			local t = math.min(moveTimer / moveDuration, 1)

			local nextPos
			if easingFunc then
				local progress = easingFunc(t)
				nextPos = addVec(moveOriginPos, scaleVec(subVec(moveTargetPos, moveOriginPos), progress))
			else
				-- movimento linear simples caso não haja easing
				local dir = normalize(subVec(moveTargetPos, entity.pos))
				nextPos = addVec(entity.pos, scaleVec(dir, entity.speed * dt))
			end

			setPos(entity, nextPos)

			-- chegou ao destino ou acabou o tempo
			if t >= 1 or dist(entity.pos, moveTargetPos) <= 4 then
				moveTargetPos = nil
				avoidCooldown = 1.0 + math.random() / 2
			end
		end
	end
end

---@param period? number
---@return MovementFunc
-- trajetória em zig zag
function zigZagMovement(period, ampDeg)
	local period = period or 0.75
	local ampDeg = ampDeg or math.rad(45)
	local time = 0

	return function(entity, dt)
		local sign = sign(math.fmod(time - period / 2, period) - period / 2)
		local newDirection = entity.direction + ampDeg * sign
		local dirVec = polarToVec(newDirection, 1)
		time = time + dt

		setPos(entity, addVec(entity.pos, scaleVec(dirVec, entity.speed)))
	end
end

---@param amplitude? rad
---@return MovementFunc
-- trajetória em formato de senoide
function sineMovement(ampDeg)
	local ampDeg = ampDeg or math.rad(60)
	local time = 0

	return function(entity, dt)
		local newAngle = entity.direction + math.sin(time * 5) * ampDeg
		local newDir = polarToVec(newAngle, 1)
		time = time + dt

		setPos(entity, addVec(entity.pos, scaleVec(newDir, entity.speed)))
	end
end

---@param turnSpeed? rad
---@return MovementFunc
-- trajetória que segue um alvo
function homingMovement(turnSpeed)
	local turnSpeed = turnSpeed or math.rad(120)

	return function(entity, dt)
		if not entity.target then
			return entity.vel
		end

		local velDir = normalize(entity.vel)
		local toTargetDir = normalize(subVec(entity.target.pos, entity.pos))

		local angleDiff = math.atan2(toTargetDir.y, toTargetDir.x) - math.atan2(velDir.y, velDir.x)

		angleDiff = (angleDiff + math.pi) % (2 * math.pi) - math.pi

		local angle = angleDiff * turnSpeed * dt
		local newDir = rotateVec(velDir, angle)

		return scaleVec(newDir, entity.speed)
	end
end

---@param threshold? number
---@return MovementFunc
-- trajetória quadrática de ataque
function quadraticMovement(threshold)
	local threshold = threshold or 80
	return function(entity, dt)
		if not entity.target then
			return entity.vel
		end

		local dx = entity.target.pos.x - entity.pos.x
		local dy = entity.target.pos.y - entity.pos.y

		local newDir = entity.vel

		if math.abs(dx) > math.abs(dy) + threshold then
			newDir.x = dx
			newDir.y = 0
		elseif math.abs(dy) > math.abs(dx) + threshold then
			newDir.y = dy
			newDir.x = 0
		end

		newDir = normalize(newDir)
		return scaleVec(newDir, entity.speed)
	end
end
