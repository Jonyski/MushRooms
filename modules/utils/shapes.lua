---------------------------------------
-- Enums
----------------------------------------
CIRCLE = "circle"
RECTANGLE = "rectangle"
LINE = "line"

---------------------------------------
-- Classe Circle
----------------------------------------

Circle = {}
Circle.__index = Circle
Circle.shape = CIRCLE

function Circle.new(radius)
	local circle = setmetatable({}, Circle)
	circle.radius = radius
	return circle
end

----------------------------------------
-- Classe Rectangle
----------------------------------------

Rectangle = {}
Rectangle.__index = Rectangle
Rectangle.shape = RECTANGLE

function Rectangle.new(width, height)
	local rect = setmetatable({}, Rectangle)
	rect.width = width
	rect.height = height
	rect.halfW = width / 2
	rect.halfH = height / 2
	return rect
end

----------------------------------------
-- Classe Line
----------------------------------------

Line = {}
Line.__index = Line
Line.shape = LINE

function Line.new(angle, length)
	local line = setmetatable({}, Line)
	line.angle = angle
	line.length = length
end
