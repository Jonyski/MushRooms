outlineShader = love.graphics.newShader("shaders/outline.glsl")
outlineShader:send("thickness", 15.0)
outlineShader:send("outlineColor", {1, 1, 1, 1})

function drawSpriteWithOutline(image, x, y, scale)
    love.graphics.setShader(outlineShader)
    love.graphics.draw(image, x - image:getWidth()/2, y - image:getHeight()/2, 0, scale, scale)
    love.graphics.setShader()
end