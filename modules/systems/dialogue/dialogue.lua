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

function Dialogue.new(graph, context)
  local dialogue = setmetatable({}, Dialogue)

  dialogue.graph = graph
  dialogue.nodes = graph.nodes
  dialogue.currentId = graph.start
  dialogue.currentNode = nil

  dialogue.context = context or {}

  dialogue.active = false

  return dialogue
end

function Dialogue:start()
  self.active = true
  self:enterNode(self.currentId)
end

function Dialogue:enterNode(nodeId)
  self.currentId = nodeId
  self.currentNode = self.nodes[nodeId]

  if not self.currentNode then
    print("[Dialogue] Node inexistente:", nodeId)
    self:endDialogue()
    return
  end

  if self.currentNode.onEnter then
    self.currentNode.onEnter(self.context)
  end
end

function Dialogue:exitNode()
  if self.currentNode and self.currentNode.onExit then
    self.currentNode.onExit(self.context)
  end
end

function Dialogue:advance()
  if not self.active then 
    return   
  end

  -- fluxo linear
  self:exitNode()

  if self.currentNode.next then
    self:enterNode(self.currentNode.next)
  else
    self:endDialogue()
  end
end

function Dialogue:endDialogue()
  self.active = false
  self.currentNode = nil
end

function Dialogue:update(dt)
  -- reservado para efeitos (typewriter, delays, etc)
end

function Dialogue:draw(x, y)
  if not self.active or not self.currentNode then 
    return
  end

  love.graphics.print(self.currentNode.text, x, y)
end