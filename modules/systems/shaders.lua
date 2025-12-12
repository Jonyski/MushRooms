outlineShader = love.graphics.newShader("shaders/outline.glsl")

---@param image table
---@param x number
---@param y number
---@param scale? number
---@param thickness? number
---@param outlineColor? Color
-- desenha uma imagem com um shader de outline (borda)
function drawSpriteWithOutline(image, x, y, scale, offset, thickness, outlineColor)
    love.graphics.setShader(outlineShader)

    -- envia os parâmetros do shader
    outlineShader:send("thickness", thickness or 1)
    outlineShader:send("outlineColor", outlineColor or { 1, 1, 1, 1 })
    outlineShader:send("texSize", { image:getWidth(), image:getHeight() })

    love.graphics.draw(image, x, y, 0, scale, scale, offset.x, offset.y)
    love.graphics.setShader()
end

