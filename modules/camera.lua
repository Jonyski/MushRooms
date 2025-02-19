----------------------------------------
-- Importações de Módulos
----------------------------------------
require "modules/player"

----------------------------------------
-- Variáveis
----------------------------------------
cameras = {}

----------------------------------------
-- Classe Camera
----------------------------------------
Camera = {}
Camera.__index = Camera

function Camera.new(pos, viewport)
	local camera = setmetatable({}, Camera)
	camera.pos = pos
	camera.viewport = viewport
	camera.cx = (pos.x + viewport.width) / 2
	camera.cy = (pos.y + viewport.height) / 2
	return camera
end

function Camera:updatePosition()
	if #cameras == 1 then
		local pos = {x = 0, y = 0}
		for _, p in pairs(players) do
			pos.x = pos.x + p.pos.x
			pos.y = pos.y + p.pos.y
		end
		self.pos.x = pos.x / #players - self.viewport.width / 2
		self.pos.y = pos.y / #players - self.viewport.height / 2
		self.cx = self.pos.x + self.viewport.width / 2
		self.cy = self.pos.y + self.viewport.height / 2

		print("x: "..self.pos.x.." y: "..self.pos.y)
		print("cx: "..self.cx.." cy: "..self.cy)
	end
end

----------------------------------------
-- Funções Globais
----------------------------------------
function newCamera()
	-- limite de cameras alcançado
	if #cameras >= 4 then return end

	if #cameras == 0 then
		local camera = Camera.new({x = 0, y = 0}, {width = window.width, height = window.height})
		table.insert(cameras, camera)
	end
end