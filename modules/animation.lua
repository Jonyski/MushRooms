----------------------------------------
-- Importações de Módulos
----------------------------------------
require "table"

----------------------------------------
-- Classe Animation
----------------------------------------
Animation = {}
Animation.__index = Animation

function Animation.new(frames, frameDur, looping, loopFrame, frameDim)
	local animation = setmetatable({}, Animation)

	-- atributos que variam
	animation.frames = frames
	animation.frameDur = frameDur
	animation.looping = looping
	animation.loopFrame = loopFrame
	animation.frameDim = frameDim
	-- atributos fixos na instanciação
	animation.currFrame = 1
	animation.timer = 0
	animation.isPlaying = true
	
	return animation
end

function Animation:update(dt)
    if not self.isPlaying then return end

    self.timer = self.timer + dt
    if self.timer > self.frameDur then
        self.timer = 0
        self.currFrame = self.currFrame + 1
        if self.currFrame > #self.frames then
        	-- volta pro primeiro frame de loop se a animação for ciclica
            self.currFrame = self.looping and self.loopFrame or #self.frames
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
			if i > length then goto createanimation end

			table.insert(frames, love.graphics.newQuad(x, y, qWidth, qHeight, sWidth, sHeight))
		end
	end

	::createanimation::
	return Animation.new(frames, frameDur, looping, loopFrame, frameDim)
end

return Animation