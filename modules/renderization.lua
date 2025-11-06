require("modules/camera")

----------------------------------------
-- Funções Globais
----------------------------------------
function renderRooms(cam)
	for i = rooms.minIndex, rooms.maxIndex do
		for j = rooms[i].minIndex, rooms[i].maxIndex do
			local r = rooms[i][j]
			if not r then
				goto nextroom
			end

			love.graphics.setColor(r.color.r, r.color.g, r.color.b, r.color.a)
			local roomViewPos = {
				x = r.hitbox.p1.x - cameras[cam].cx + cameras[cam].viewport.width / 2,
				y = r.hitbox.p1.y - cameras[cam].cy + cameras[cam].viewport.height / 2,
			}
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
function renderEntities(cam)
	local camera = cameras[cam]
	local drawList = {}

	-- Adiciona jogadores e suas possíveis armas
	for _, p in pairs(players) do
		table.insert(drawList, {
			y = p.pos.y, -- referência para ordenação
			draw = function()
				p:draw(camera)
			end,
		})
		if p.weapon then
			local w = p.weapon
			local offsetY = (w.rotation / math.pi < -1 or w.rotation / math.pi > 0) and 2 or -2
			table.insert(drawList, {
				y = p.pos.y + offsetY, -- mesma altura do jogador, mas deslocado para frente ou para trás
				draw = function()
					w:draw(camera)
				end,
			})
		end
		for _, w in pairs(p.weapons) do
			for _, e in ipairs(w.atk.events) do
				e:draw(camera)
			end
		end
	end

	-- Adiciona inimigos
	for _, e in pairs(enemies) do
		table.insert(drawList, {
			y = e.pos.y,
			draw = function()
				e:draw(camera)
			end,
		})
	end

	-- Ordena por posição Y
	table.sort(drawList, function(a, b)
		return a.y < b.y
	end)

	-- Desenha na ordem correta
	for _, item in ipairs(drawList) do
		item.draw()
	end
end
