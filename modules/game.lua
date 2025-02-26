----------------------------------------
-- Funções Globais
----------------------------------------
function renderRooms(cam)

	for i = rooms.minIndex, rooms.maxIndex do
		for j = rooms[i].minIndex, rooms[i].maxIndex do
			local r = rooms[i][j]
			love.graphics.setColor(r.color.r, r.color.g, r.color.b, r.color.a)
			local roomWorldPos = {x = r.pos.x * 400 + 5,
			                      y = r.pos.y * 400 + 5}
			local roomViewPos = {x = roomWorldPos.x - cameras[cam].cx + cameras[cam].viewport.width / 2,
			                     y = roomWorldPos.y - cameras[cam].cy + cameras[cam].viewport.height / 2}
			love.graphics.rectangle("fill", roomViewPos.x, roomViewPos.y, r.dimensions.width, r.dimensions.height, 5, 5)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end
end

function renderPlayers(cam)
	for _, p in pairs(players) do
		pViewPos = {x = p.pos.x - cameras[cam].cx + cameras[cam].viewport.width / 2,
		            y = p.pos.y - cameras[cam].cy + cameras[cam].viewport.height / 2}
		love.graphics.setColor(p.color.r, p.color.g, p.color.b, p.color.a)
		love.graphics.circle("fill", pViewPos.x, pViewPos.y, 20)
		love.graphics.setColor(1, 1, 1, 1)
	end
end