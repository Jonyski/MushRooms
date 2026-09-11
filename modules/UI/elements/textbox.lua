----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.UI.uielement")
local utf8 = require("utf8")

----------------------------------------
-- Classe UITextBox
----------------------------------------

UITextBox = setmetatable({}, { __index = UIElement })
UITextBox.__index = UITextBox

---@param name string
---@param pos Vec
---@param size Size
---@param hitboxes Hitboxes
---@param color table
---@param maxLength number
---@param onTextChanged function
function UITextBox.new(name, pos, size, hitboxes, color, maxLength, onTextChanged)
    local textbox = setmetatable({}, UITextBox)
    textbox:init(name, UI_TEXTBOX_ELEM, pos, size, hitboxes)
    textbox.color = color or { r = 1, g = 1, b = 1, a = 1 }
    textbox.text = ""
    textbox.maxLength = maxLength or 50
    textbox.onTextChanged = onTextChanged
    textbox.cursorTimer = 0 -- para fazer o cursor piscar
    return textbox
end

-- lida com caracteres digitados (em qualquer idioma, em teoria)
function UITextBox:handleTextInput(t)
    -- só aceita texto se este elemento estiver selecionado e houver espaço
    if t and utf8.len(self.text) < self.maxLength then
        self.text = self.text .. t

        -- dispara o callback informando o novo estado do texto
        if self.onTextChanged then
            self.onTextChanged(self.text)
        end
    end
end

-- lida com teclas de controle
function UITextBox:keyPressed(key)
    if not self.selected then
        return
    end

    if key == "backspace" then
        -- lógica de backspace segura para UTF-8 (acentos)
        local byteoffset = utf8.offset(self.text, -1)
        if byteoffset then
            self.text = string.sub(self.text, 1, byteoffset - 1)
            if self.onTextChanged then
                self.onTextChanged(self.text)
            end
        end
    elseif key == "return" then
        -- finaliza a edição quando o jogador aperta Enter
        self:deselect()
    end
end

function UITextBox:update(dt)
    UIElement.update(self, dt)

    if self.selected then
        self.cursorTimer = self.cursorTimer + dt
    end
end

function UITextBox:draw(camera)
    local viewX = self.pos.x
    local viewY = self.pos.y
    if camera then
        viewX, viewY = camera:viewPos(self.pos)
    end

    -- desenha a sprite/background se houver
    UIElement.draw(self, camera)

    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)

    -- lógica para o cursor piscando
    local displayText = self.text
    if self.selected and math.floor(self.cursorTimer * 2) % 2 == 0 then
        displayText = displayText .. "|"
    end

    -- desenhando o texto
    love.graphics.setFont(mushBigFont)
    love.graphics.printf(displayText, viewX - self.size.width / 2 + 40, viewY - 20, self.size.width, "left", 0, 1, 1)
    love.graphics.setFont(mushFont)
    love.graphics.setColor(1, 1, 1, 1)
end
