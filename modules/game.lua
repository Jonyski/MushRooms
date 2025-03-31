----------------------------------------
-- Funções Globais
----------------------------------------
function renderRooms(cam)

	for i = rooms.minIndex, rooms.maxIndex do
		for j = rooms[i].minIndex, rooms[i].maxIndex do
			local r = rooms[i][j]
			if not r then goto nextroom end
			love.graphics.setColor(r.color.r, r.color.g, r.color.b, r.color.a)
			local roomWorldPos = {x = r.pos.x * 600 + 100,
	            				  y = r.pos.y * 600 + 100}
			local roomViewPos = {x = roomWorldPos.x - cameras[cam].cx + cameras[cam].viewport.width / 2,
			                     y = roomWorldPos.y - cameras[cam].cy + cameras[cam].viewport.height / 2}
			love.graphics.rectangle("fill", roomViewPos.x, roomViewPos.y, r.dimensions.width, r.dimensions.height, 5, 5)

			-- debugging visual --------------
			love.graphics.setColor(0, 0, 0, 1)
			local text = "("..r.hitbox.p1.x..", "..r.hitbox.p1.y..") - ("..r.hitbox.p2.x..", "..r.hitbox.p2.y..")"
			love.graphics.print(text, roomViewPos.x, roomViewPos.y, 0, 2, 2, 0, 0, 0, 0)
			----------------------------------

			love.graphics.setColor(1, 1, 1, 1)
			::nextroom::
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