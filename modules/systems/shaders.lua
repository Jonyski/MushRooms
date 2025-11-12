outlineShader = love.graphics.newShader("shaders/outline.glsl")
outlineShader:send("thickness", 15.0)
outlineShader:send("outlineColor", {1, 1, 1, 1})

function drawSpriteWithOutline(image, x, y, scale, offset)
    love.graphics.setShader(outlineShader)
    love.graphics.draw(image, x, y, 0, scale, scale, offset.x, offset.y)
    love.graphics.setShader()
end