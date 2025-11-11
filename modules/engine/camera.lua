----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.player")
require("modules.utils.utils")

----------------------------------------
-- Variáveis
----------------------------------------
cameras = {}

----------------------------------------
-- Classe Camera
----------------------------------------
Camera = {}
Camera.__index = Camera

function Camera.new(pos, viewport, canvas, canvasPos)
	local camera = setmetatable({}, Camera)

	camera.pos = pos          -- posição da camera
	camera.viewport = viewport -- tamanho da câmera (o espaço que ela enxerga)
	camera.canvas = canvas    -- canvas associado à câmera
	camera.canvasPos = canvasPos -- posição do canvas na tela
	camera.cx = (pos.x + viewport.width) / 2
	camera.cy = (pos.y + viewport.height) / 2
	camera.targetPos = { x = pos.x, y = pos.y } -- onde a câmera deve ir
	-- atributos fixos na instanciação
	camera.transitionSpeed = 6               -- controla a suavidade da transição
	camera.shakeOffset = { x = 0, y = 0 }    -- deslocamento atual do shake
	camera.shakeIntensity = 0                -- intensidade do shake
	camera.shakeDuration = 0                 -- duração total do shake
	camera.shakeTimer = 0                    -- tempo restante do shake
	camera.zoom = 1                          -- zoom atual
	camera.targetZoom = 1                    -- zoom desejado
	camera.zoomSpeed = 3                     -- velocidade da transição

	return camera
end

function Camera:updatePosition(dt)
	-- ajuda o viewport de acordo com o zoom
	local viewportZoomed = {
		width = self.viewport.width / self.zoom,
		height = self.viewport.height / self.zoom,
	}
	-- TODO: câmera única quando os jogadores estão próximos
	if #cameras == 1 and #players > 1 then
		local pos = { x = 0, y = 0 }
		for _, p in pairs(players) do
			pos.x = pos.x + p.pos.x
			pos.y = pos.y + p.pos.y
		end
		self.targetPos.x = pos.x / #players - viewportZoomed.width / 2
		self.targetPos.y = pos.y / #players - viewportZoomed.height / 2
	else
		-- a câmera segue os jogadores individualmente
		local i = tableFind(cameras, self)
		local player = players[i]
		local room = player.room

		-- limita a posição da câmera ao hitbox da sala
		self.targetPos.x =
			clamp(player.pos.x - viewportZoomed.width / 2, room.hitbox.p1.x, room.hitbox.p2.x - viewportZoomed.width)
		self.targetPos.y =
			clamp(player.pos.y - viewportZoomed.height / 2, room.hitbox.p1.y, room.hitbox.p2.y - viewportZoomed.height)
	end

	-- atualiza shake se estiver ativo
	if self.shakeTimer > 0 then
		self.shakeTimer = self.shakeTimer - dt
		local progress = self.shakeTimer / self.shakeDuration

		-- gera deslocamento aleatório (intensidade decresce)
		local intensity = self.shakeIntensity * progress
		self.shakeOffset.x = (math.random() - 0.5) * intensity
		self.shakeOffset.y = (math.random() - 0.5) * intensity

		if self.shakeTimer <= 0 then
			self.shakeOffset.x = 0
			self.shakeOffset.y = 0
		end
	end

	-- suaviza o movimento até o target
	self.pos.x = lerp(self.pos.x, self.targetPos.x, dt * self.transitionSpeed)
	self.pos.y = lerp(self.pos.y, self.targetPos.y, dt * self.transitionSpeed)

	-- atualiza centro
	self.cx = self.pos.x + viewportZoomed.width / 2 + self.shakeOffset.x
	self.cy = self.pos.y + viewportZoomed.height / 2 + self.shakeOffset.y

	-- suaviza o zoom atual
	self.zoom = lerp(self.zoom, self.targetZoom, dt * self.zoomSpeed)
end

function Camera:shake(intensity, duration)
	self.shakeIntensity = intensity or 10
	self.shakeDuration = duration or 0.3
	self.shakeTimer = self.shakeDuration
end

function Camera:viewPos(entityPos)
	return {
		x = entityPos.x - self.cx + self.viewport.width / 2,
		y = entityPos.y - self.cy + self.viewport.height / 2,
	}
end

----------------------------------------
-- Função de Renderização
----------------------------------------
function Camera:draw()
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear(0.0, 0.0, 0.0, 1.0)
	love.graphics.push()

	-- centraliza o zoom
	love.graphics.translate(self.viewport.width / 2, self.viewport.height / 2)
	love.graphics.scale(self.zoom)
	love.graphics.translate(-self.viewport.width / 2, -self.viewport.height / 2)

	-- renderiza mundo
	renderRooms(self)
	renderEntities(self)

	love.graphics.pop()
	love.graphics.setCanvas()
	love.graphics.draw(self.canvas, self.canvasPos.x, self.canvasPos.y)
end

----------------------------------------
-- Funções Globais
----------------------------------------
function newCamera()
	-- limite de cameras alcançado
	if #cameras >= 4 then
		return
	end

	local numOfCams = #cameras + 1
	for i = 1, #cameras do
		cameras[i] = nil
	end

	for i = 1, numOfCams do
		if numOfCams <= 3 then
			local camera = Camera.new(
				{ x = 0, y = 0 },
				{ width = window.width / numOfCams, height = window.height },
				love.graphics.newCanvas(window.width / numOfCams, window.height),
				{ x = (i - 1) * (window.width / numOfCams), y = 0 }
			)
			table.insert(cameras, camera)
		else -- no caso de 4 câmeras
			local canvasPositions = {
				{ x = 0,                y = 0 },
				{ x = window.width / 2, y = 0 },
				{ x = 0,                y = window.height / 2 },
				{ x = window.width / 2, y = window.height / 2 },
			}
			local camera = Camera.new(
				{ x = 0, y = 0 },
				{ width = window.width / 2, height = window.height / 2 },
				love.graphics.newCanvas(window.width / 2, window.height / 2),
				canvasPositions[i]
			)
			table.insert(cameras, camera)
		end
	end
end
