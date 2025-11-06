----------------------------------------
-- Classe Color
----------------------------------------
Color = {}
Color.__index = Color

function Color.new(r, g, b, a)
    local c = setmetatable({}, Color)
    c.r = clamp(r, 0, 1)
    c.g = clamp(g, 0, 1)
    c.b = clamp(b, 0, 1)
    c.a = clamp(a, 0, 1)
    return c
end

----------------------------------------
-- Funções Globais
----------------------------------------
function getP1ColorPalette()
    local palette = {}
    table.insert(palette, Color.new(1.0, 0.11, 0.2, 1.0))
    table.insert(palette, Color.new(1.0, 0.88, 0.44, 1.0))
    table.insert(palette, Color.new(0.08, 0.75, 0.39, 1.0))
    return palette
end

function getP2ColorPalette()
    local palette = {}
    table.insert(palette, Color.new(0.2, 0.52, 0.89, 1.0))
    table.insert(palette, Color.new(0.59, 0.16, 0.94, 1.0))
    table.insert(palette, Color.new(0.43, 0.96, 0.83, 1.0))
    return palette
end

function getP3ColorPalette()
    local palette = {}
    table.insert(palette, Color.new(0.79, 0.06, 0.17, 1.0))
    table.insert(palette, Color.new(0.94, 0.45, 0.19, 1.0))
    table.insert(palette, Color.new(0.92, 0.85, 0.28, 1.0))
    return palette
end

function getP4ColorPalette()
    local palette = {}
    table.insert(palette, Color.new(0.92, 0.16, 0.54, 1.0))
    table.insert(palette, Color.new(0.2, 0.41, 0.91, 1.0))
    table.insert(palette, Color.new(0.56, 0.15, 0.88, 1.0))
    return palette
end
