require "modules/camera"

----------------------------------------
-- Funções Globais
----------------------------------------
function renderRooms(cam)
	for i = rooms.minIndex, rooms.maxIndex do
		for j = rooms[i].minIndex, rooms[i].maxIndex do
			local r = rooms[i][j]
			if not r then goto nextroom end
			
			love.graphics.setColor(r.color.r, r.color.g, r.color.b, r.color.a)
			local roomViewPos = {x = r.hitbox.p1.x - cameras[cam].cx + cameras[cam].viewport.width / 2,
			                     y = r.hitbox.p1.y - cameras[cam].cy + cameras[cam].viewport.height / 2}
			love.graphics.draw(r.sprites.floor, roomViewPos.x, roomViewPos.y, 0, 6, 6)

			-- reseta a cor de renderização
			love.graphics.setColor(1, 1, 1, 1)
			::nextroom::
		end
	end
end

function renderPlayers(cam)
	for _, p in pairs(players) do
		local pViewPos = {x = p.pos.x - cameras[cam].cx + cameras[cam].viewport.width / 2,
		            y = p.pos.y - cameras[cam].cy + cameras[cam].viewport.height / 2}
		love.graphics.setColor(p.color.r, p.color.g, p.color.b, p.color.a)
		local animation = p.animations[p.state]
		local quad = animation.frames[animation.currFrame]
		local offset = {x = animation.frameDim.width / 2, y = animation.frameDim.height / 2}
		love.graphics.setColor(1, 1, 1, 1) -- mudar depois para efeitos de iluminação
		love.graphics.draw(p.spriteSheets[p.state], quad, pViewPos.x, pViewPos.y, 0, 3, 3, offset.x, offset.y)
		
		-- reseta a cor de renderização
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function renderEnemies(cam)
	for _, e in pairs(enemies) do
		local eViewPos = {x = e.pos.x - cameras[cam].cx + cameras[cam].viewport.width / 2,
		            y = e.pos.y - cameras[cam].cy + cameras[cam].viewport.height / 2}
		love.graphics.setColor(e.color.r, e.color.g, e.color.b, e.color.a)
		local offset = {x = e.size.width/2, y = e.size.height/2}
		love.graphics.rectangle("fill", eViewPos.x, eViewPos.y, e.size.width, e.size.height, 0, 1, 1, offset.x, offset.y)

		-- reseta a cor de renderização
		love.graphics.setColor(1, 1, 1, 1)
	end
end

function renderWeapons(cam)
	for _, e in pairs(players) do
		local wViewPos = {x = e.pos.x - cameras[cam].cx + cameras[cam].viewport.width / 2,
		            y = e.pos.y - cameras[cam].cy + cameras[cam].viewport.height / 2}
		love.graphics.push()
		love.graphics.translate(wViewPos.x, wViewPos.y)
		love.graphics.rotate(e.weapon.rotation)
		local color = e.weapon.color
		love.graphics.setColor(color.r, color.g, color.b, color.a)
		love.graphics.rectangle("fill", 0, -e.weapon.size.height / 2, e.weapon.size.width, e.weapon.size.height)
		love.graphics.pop()
		-- reseta a cor de renderização
		love.graphics.setColor(1, 1, 1, 1)
	end
end