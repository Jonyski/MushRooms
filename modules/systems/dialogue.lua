----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.types")
require("modules.flags")
require("table")

----------------------------------------
-- Classe Diálogo
----------------------------------------

---@class Dialogue
---@field intro table<string> Sequência introdutória
---@field loop table<string> Sequência padrão (loop)
---@field event table<table<string>> Sequências de evento (condicionais)
---@field owner Npc Dono do diálogo
---@field talkingWith Player Jogador que está falando
---@field activeSequence table<string> Sequência ativa atual
---@field active boolean Se o diálogo está ativo

Dialogue = {}
Dialogue.__index = Dialogue
Dialogue.type = DIALOGUE

---@returns Dialogue
-- cria uma nova instância de diálogo
function Dialogue.new(list)
  local dialogue = setmetatable({}, Dialogue)

  dialogue.intro = list.intro
  dialogue.loop = list.loop
  dialogue.event = list.event

  dialogue.owner = nil
  dialogue.talkingWith = nil

  dialogue.activeSequence = nil
  dialogue.active = false

  return dialogue
end

function Dialogue:start()
  self.active = true
  self.talkingWith.inDialogue = true
  self.owner.inDialogue = true

  local playerCamera = getCameraByPlayer(self.talkingWith)
  if playerCamera then
    playerCamera:changeTarget(self.owner)
  end

  -- diálogo introdutório
  if self.intro.triggered ~= true then
    self.activeSequence = self.intro
  else
    -- diálogos de evento (condicionais)
    for i = #self.event, 1, -1 do
      local entry = self.event[i]

      if entry.condition and entry.condition(self.talkingWith, self.owner, flagsTable) and entry.triggered ~= true then
        self.activeSequence = entry
      end
    end

    -- diálogo padrão (loop)
    if not self.activeSequence then
      self.activeSequence = self.loop
    end
  end

  self.activeSequence.idx = 1
end

function Dialogue:advance()
  if not self.active or not self.activeSequence then 
    return   
  end

  if self.activeSequence.idx < #self.activeSequence.text then
    self.activeSequence.idx = self.activeSequence.idx + 1
  else
    self:endDialogue()
  end
end

function Dialogue:endDialogue()
  if self.activeSequence.triggered ~= nil then
    self.activeSequence.triggered = true
  end

  local playerCamera = getCameraByPlayer(self.talkingWith)
  if playerCamera then
    playerCamera:changeTarget(self.talkingWith)
  end

  self.talkingWith.inDialogue = false
  self.owner.inDialogue = false
  self.active = false
  self.activeSequence.idx = -1
  self.activeSequence = nil
end

function Dialogue:update(dt)
  -- reservado para efeitos (typewriter, delays, etc)
end

function Dialogue:draw(camera)
  if not self.active or not self.activeSequence then 
    return
  end

  local text = self.activeSequence.text[self.activeSequence.idx]

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

----------------------------------------
-- Dialog Manager
----------------------------------------

DialogueManager = {}
DialogueManager.dialogues = {}
DialogueManager.current = nil
DialogueManager.context = {}

---@param dialogue Dialogue
---@param owner Npc
---@param player Player
-- inicia um diálogo entre um NPC e um jogador
function DialogueManager:start(dialogue, owner, player)
  if self.dialogues[owner] then
    return
  end

  print("Iniciando diálogo entre " .. owner.name .. " e " .. player.name)
  self.dialogues[owner] = dialogue

  dialogue.owner = owner
  dialogue.talkingWith = player

  dialogue:start()
end

---@param dialogue Dialogue
-- limpa um diálogo finalizado
function DialogueManager:cleanDialogue(dialogue)
  if self.dialogues[dialogue.owner] then
    self.dialogues[dialogue.owner] = nil
    print("Finalizando diálogo...")
  end
end

---@param dt number
-- atualiza todos os diálogos ativos
function DialogueManager:update(dt)
  for _, dialogue in pairs(self.dialogues) do
    dialogue:update(dt)

    if not dialogue.active then
      self:cleanDialogue(dialogue)
    end
  end
end

function DialogueManager:getDialogueByPlayer(player)
  for _, dialogue in pairs(self.dialogues) do
    if dialogue.talkingWith == player then
      return dialogue
    end
  end
  return nil
  
end