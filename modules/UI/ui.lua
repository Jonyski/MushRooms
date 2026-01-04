----------------------------------------
-- Variáveis globais
----------------------------------------

-- usaremos como constante base para definir a escala do mundo
INITIAL_WINDOW_WIDTH = 1280
INITIAL_WINDOW_HEIGHT = 720

----------------------------------------
-- Funções globais
----------------------------------------

-- importa e define as configurações iniciais do LUIS
function setupLUIS()
	local reqPath = love.filesystem.getRequirePath()
	love.filesystem.setRequirePath(reqPath .. ";libs/?.lua;")
	local initLuis = require("luis.init")
	luis = initLuis("libs/luis/widgets")
	luis.flux = require("luis.3rdparty.flux")
	luis.baseWidth = INITIAL_WINDOW_WIDTH
	luis.baseHeight = INITIAL_WINDOW_HEIGHT
	luis.setGridSize(16)
end

---@param viewPos Vec
---@return number, number
-- dadas as coordenadas de um widget em um canvas,
-- devolve a linha e a coluna dele no grid do LUIS
-- ! Não usada atualmente !
function viewPosToGrid(viewPos)
	local column = (viewPos.x / luis.scale / luis.gridSize) + 1
	local row = (viewPos.y / luis.scale / luis.gridSize) + 1
	return column, row
end

---@param widget table
---@param cam Camera
---@param worldPos Vec
-- redefine a posição em que um widget deve ser atualizado
-- ! Não usada atualmente !
function updateWidgetPos(widget, cam, worldPos)
	if not widget then
		return
	end
	local viewPos = cam:viewPos(worldPos)
	local column, row = viewPosToGrid(viewPos)
	widget.position.x = (column - 1) * luis.gridSize
	widget.position.y = (row - 1) * luis.gridSize
end
