function setupLUIS()
	local reqPath = love.filesystem.getRequirePath()
	love.filesystem.setRequirePath(reqPath .. ";libs/?.lua;")
	local initLuis = require("luis.init")
	luis = initLuis("libs/luis/widgets")
	luis.flux = require("luis.3rdparty.flux")
	luis.baseWidth = 1280
	luis.baseHeight = 720
	luis.setGridSize(16)
end
