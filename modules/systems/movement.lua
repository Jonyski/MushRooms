---@alias MovementFunc fun(entity: any, dt: number): nil

---@param pos Vec
-- atualiza a posição da entidade `entity` e sua hitbox (caso ela exista)
function setPos(entity, pos)
	entity.pos = pos
	if entity.hb then
		entity.hb.pos = pos
	end
end

---@param entity any
---@param targetPos Vec
---@param dt number
-- se move na direção de um ponto específico.
-- `entity` precisa ter um atributo `entity.speed` indicando sua velocidade
function moveTowards(entity, targetPos, dt)
	local direction = normalize(subVec(targetPos, entity.pos))
	local movement = scaleVec(direction, entity.speed * dt)
	setPos(entity, addVec(entity.pos, movement))
end
