----------------------------------------
-- Importações de Módulos
----------------------------------------
require("table")

----------------------------------------
-- Classe Animation
----------------------------------------
Animation = {}
Animation.__index = Animation

function Animation.new(frames, frameDur, looping, loopFrame, frameDim)
	local animation = setmetatable({}, Animation)

	-- atributos que variam
	animation.frames = frames -- número de frames na animação
	animation.frameDur = frameDur -- duração de cada frame em segundos
	animation.looping = looping -- se a animação é ciclica ou não
	animation.loopFrame = loopFrame -- a partir de qual frame a animação é ciclica
	animation.frameDim = frameDim -- dimensões de cada frame
	-- atributos fixos na instanciação
	animation.currFrame = 1 -- frame atual
	animation.timer = 0 -- tempo decorrido desde a última mudança de frame
	animation.onFinish = nil -- callback chamado quando a animação não-loop termina

	return animation
end

function Animation:update(dt)
	self.timer = self.timer + dt
	if self.timer > self.frameDur then
		self.timer = 0
		self.currFrame = self.currFrame + 1

		-- atingiu o fim da animação
		if self.currFrame > #self.frames then
			if self.looping then
				-- volta pro primeiro frame de loop se a animação for ciclica
				self.currFrame = self.loopFrame
			else
				-- trava no último frame e chama callback se existir
				self.currFrame = #self.frames
				if self.onFinish then
					self.onFinish(self)
				end
			end
		end
	end
end

function Animation:reset()
	self.currFrame = 1
end

----------------------------------------
-- Funções Globais
----------------------------------------
function newAnimation(path, length, quadSize, frameDur, looping, loopFrame, frameDim)
	local sheetImg = love.graphics.newImage(path)
	local frames = {}
	local gap = 4
	local sWidth = sheetImg:getWidth()
	local sHeight = sheetImg:getHeight()
	local qWidth = quadSize.width
	local qHeight = quadSize.height
	local i = 0

	for y = 0, sHeight - qHeight, qHeight + gap do
		for x = 0, sWidth - qWidth, qWidth + gap do
			i = i + 1
			if i > length then
				goto createanimation
			end

			table.insert(frames, love.graphics.newQuad(x, y, qWidth, qHeight, sWidth, sHeight))
		end
	end

	::createanimation::
	return Animation.new(frames, frameDur, looping, loopFrame, frameDim)
end

---@class AnimSettings
---@field numFrames number
---@field quadSize Size
---@field frameDur number
---@field looping boolean
---@field loopFrame number

---@param numFrames number
---@param quadSize Size
---@param frameDur number
---@param looping boolean
---@param loopFrame number?
---@return AnimSettings
-- cria uma cofiguração de animação, usada para criar novas animações
function newAnimSetting(numFrames, quadSize, frameDur, looping, loopFrame)
	return {
		numFrames = numFrames,
		quadSize = quadSize,
		frameDur = frameDur,
		looping = looping,
		loopFrame = loopFrame,
	}
end

---@param entity any
---@param path any
---@param action any
---@param settings any
-- atrela uma animação com configuração `setting` à ação
-- `action` da entidade `entity`. `path` é o caminho para
-- o sprite sheet da animação
function addAnimation(entity, path, action, settings)
	local animation = newAnimation(
		path,
		settings.numFrames,
		settings.quadSize,
		settings.frameDur,
		settings.looping,
		settings.loopFrame,
		settings.quadSize
	)
	entity.animations[action] = animation
	entity.spriteSheets[action] = love.graphics.newImage(path)
	entity.spriteSheets[action]:setFilter("nearest", "nearest")
end

return Animation
