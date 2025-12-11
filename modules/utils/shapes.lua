---------------------------------------
-- Enums
----------------------------------------
CIRCLE = "circle"
RECTANGLE = "rectangle"
LINE = "line"

---------------------------------------
-- Classe Circle
----------------------------------------

---@class Circle Um círculo representado pelo raio
---@field radius number
Circle = {}
Circle.__index = Circle
Circle.shape = CIRCLE

---@param radius any
---@return Circle
-- cria uma instância de `Circle`
function Circle.new(radius)
	local circle = setmetatable({}, Circle)
	circle.radius = radius
	return circle
end

----------------------------------------
-- Classe Rectangle
----------------------------------------

---@class Rectangle Um retângulo representado por sua altura e largura
---@field width number
---@field height number
---@field halfW number
---@field halfH number
Rectangle = {}
Rectangle.__index = Rectangle
Rectangle.shape = RECTANGLE

---@param width number
---@param height number
---@return Rectangle
-- cria uma instância de `Rectangle`
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

---@class Line Uma linha representada em coordenadas polares
---@field angle rad
---@field length number
Line = {}
Line.__index = Line
Line.shape = LINE

---@param angle number
---@param length number
---@return Line
-- cria uma instância de `Line`
function Line.new(angle, length)
	local line = setmetatable({}, Line)
	line.angle = angle
	line.length = length
	return line
end
