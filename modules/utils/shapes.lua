----------------------------------------
-- Classe Circle
----------------------------------------

Circle = {}
Circle.__index = Circle
Circle.shape = "circle" -- We use this type for the dispatch

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
Rectangle.shape = "rectangle" -- We use this type for the dispatch

function Rectangle.new(width, height)
    local rect = setmetatable({}, Rectangle)
    rect.width = width
    rect.height = height
    rect.half_w = width / 2
    rect.half_h = height / 2
    return rect
end

----------------------------------------
-- Classe Line
----------------------------------------

Line = {}
Line.__index = Line
Line.shape = "line"

function Line.new(angle, length)
    local line = setmetatable({}, Line)
    line.angle = angle
    line.length = length
end
