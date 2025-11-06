----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules/player")
require("modules/utils")

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
	camera.pos = pos -- posição da camera
	camera.viewport = viewport -- tamanho da câmera (o espaço que ela enxerga)
	camera.canvas = canvas -- canvas associado à câmera
	camera.canvasPos = canvasPos -- posição do canvas na tela
	camera.cx = (pos.x + viewport.width) / 2
	camera.cy = (pos.y + viewport.height) / 2
	return camera
end

function Camera:updatePosition()
	-- TODO: câmera única quando os jogadores estão próximos
	if #cameras == 1 then
		local pos = { x = 0, y = 0 }
		for _, p in pairs(players) do
			pos.x = pos.x + p.pos.x
			pos.y = pos.y + p.pos.y
		end
		self.pos.x = pos.x / #players - self.viewport.width / 2
		self.pos.y = pos.y / #players - self.viewport.height / 2
		self.cx = self.pos.x + self.viewport.width / 2
		self.cy = self.pos.y + self.viewport.height / 2
	else
		-- A câmera segue os jogadores
		local i = tableFind(cameras, self)
		self.pos.x = players[i].pos.x - self.viewport.width / 2
		self.pos.y = players[i].pos.y - self.viewport.height / 2
		self.cx = players[i].pos.x
		self.cy = players[i].pos.y
	end
end

function Camera:viewPos(entityPos)
	return {
		x = entityPos.x - self.cx + self.viewport.width / 2,
		y = entityPos.y - self.cy + self.viewport.height / 2,
	}
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
				{ x = 0, y = 0 },
				{ x = window.width / 2, y = 0 },
				{ x = 0, y = window.height / 2 },
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
