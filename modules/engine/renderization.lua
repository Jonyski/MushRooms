require("modules.utils.anchors")
require("modules.engine.camera")

----------------------------------------
-- Funções Globais
----------------------------------------

---@param camera Camera
-- renderiza as salas na perspectiva da `camera`
function renderRooms(camera)
	for i = rooms.minIndex, rooms.maxIndex do
		for j = rooms[i].minIndex, rooms[i].maxIndex do
			local r = rooms[i][j]
			if not r then
				goto nextroom
			end

			love.graphics.setColor(r.color.r, r.color.g, r.color.b, r.color.a)
			local roomViewPos = camera:viewPos(r.hitbox.p1)
			love.graphics.draw(r.sprites.floor, roomViewPos.x, roomViewPos.y, 0, 6, 6)

			-- reseta a cor de renderização
			love.graphics.setColor(1, 1, 1, 1)
			::nextroom::
		end
	end
end

----------------------------------------
-- Funções de Renderização Global
----------------------------------------

---@param camera Camera
-- renderiza as demais entidades (além das salas) na perspecitiva da `camera`
function renderEntities(camera)
	local drawList = {}

	for _, r in activeRooms:iter() do
		-- Adiciona destrutíveis
		for _, d in pairs(r.destructibles) do
			table.insert(drawList, {
				y = d.pos.y + getAnchor(d, FLOOR),
				draw = function()
					d:draw(camera)
				end,
			})
		end
		-- Adiciona items
		for _, i in pairs(r.items) do
			table.insert(drawList, {
				y = i.floorY + getAnchor(i, FLOOR),
				draw = function()
					i:draw(camera)
				end,
			})
		end
		-- Adiciona inimigos
		for _, e in pairs(r.enemies) do
			table.insert(drawList, {
				y = e.pos.y + getAnchor(e, FLOOR),
				draw = function()
					e:draw(camera)
				end,
			})
			-- Adiciona ataques de inimigos
			if e.attackObj then
				for _, ev in pairs(e.attackObj.events) do
					ev:draw(camera)
				end
			end
		end
		-- Adiciona NPCs
		for _, npc in pairs(r.npcs) do
			table.insert(drawList, {
				y = npc.pos.y + getAnchor(npc, FLOOR),
				draw = function()
					npc:draw(camera)
				end,
			})
		end
	end

	-- Adiciona jogadores e suas possíveis armas
	for _, p in pairs(players) do
		table.insert(drawList, {
			y = p.pos.y + getAnchor(p, FLOOR),
			draw = function()
				p:draw(camera)
			end,
		})

		if p.weapon then
			local w = p.weapon
			local offsetY = (w.rotation / math.pi < -1 or w.rotation / math.pi > 0) and 2 or -2
			table.insert(drawList, {
				y = p.pos.y + getAnchor(p, FLOOR) + offsetY, -- mesma altura do jogador, mas deslocado para frente ou para trás
				draw = function()
					w:draw(camera)
				end,
			})
		end

		for _, w in pairs(p.weapons) do
			for _, e in pairs(w.atk.events) do
				e:draw(camera)
			end
		end
	end

	-- Ordena por posição Y
	table.sort(drawList, function(a, b)
		return a.y < b.y
	end)

	-- Desenha na ordem correta
	for _, obj in ipairs(drawList) do
		obj.draw()
	end
end
