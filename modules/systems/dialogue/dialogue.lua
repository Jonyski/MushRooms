----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.dialogue.dialogue_manager")
require("modules.utils.types")
require("table")

----------------------------------------
-- Classe Diálogo
----------------------------------------

---@class Dialogue

Dialogue = {}
Dialogue.__index = Dialogue
Dialogue.type = DIALOGUE

function Dialogue.new(list)
  local dialogue = setmetatable({}, Dialogue)

  dialogue.list = list
  dialogue.currentId = nil
  dialogue.idx = -1

  dialogue.owner = nil
  dialogue.triggeredBy = nil
  dialogue.active = false

  return dialogue
end

function Dialogue:start()
  self.active = true
  self.idx = 1

  if self.list["intro"].triggered ~= true then
    self.currentId = "intro"
  else
    for id, entry in pairs(self.list) do
      if entry.condition and entry.condition(self.triggeredBy) and entry.triggered ~= true then
        print("Condição satisfeita para diálogo: ", id)
        self.currentId = id
        return
      end
    end

    self.currentId = "met"
  end
end

function Dialogue:advance()
  if not self.active then 
    return   
  end

  if self.idx < #self.list[self.currentId].text then
    self.idx = self.idx + 1
  else
    self:endDialogue()
  end
end

function Dialogue:endDialogue()
  if self.list[self.currentId].triggered ~= nil then
    self.list[self.currentId].triggered = true
  end

  self.active = false
  self.idx = -1
  self.currentId = nil
end

function Dialogue:update(dt)
  -- reservado para efeitos (typewriter, delays, etc)
end

function Dialogue:draw(camera)
  if not self.active or self.idx == -1 then 
    return
  end

  local text = self.list[self.currentId].text[self.idx]

  if self.owner and self.owner.pos then
    local viewPos = camera:viewPos(vec(self.owner.pos.x, self.owner.pos.y - 80))
    local width = 300 -- largura da caixa de diálogo

    love.graphics.setFont(tempFont)
    love.graphics.printf(
      text,
      viewPos.x - width / 2,
      viewPos.y,
      width,
      "center"
    )
    
  else 
    love.graphics.print(text, 50, love.graphics.getHeight() - 120)
  end

end