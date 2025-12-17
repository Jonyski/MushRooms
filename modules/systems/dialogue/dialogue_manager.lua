DialogueManager = {}
DialogueManager.dialogues = {}
DialogueManager.current = nil
DialogueManager.context = {}

function DialogueManager:start(dialogue, owner, player)
  if self.dialogues[owner] then
    return
  end

  print("Iniciando diálogo...")
  self.dialogues[owner] = dialogue

  dialogue.owner = owner
  dialogue.triggeredBy = player

  dialogue:start()
end

function DialogueManager:cleanDialogue(dialogue)
  if self.dialogues[dialogue.owner] then
    self.dialogues[dialogue.owner] = nil
    print("Finalizando diálogo...")
  end
end

function DialogueManager:update(dt)
  for _, dialogue in pairs(self.dialogues) do
    dialogue:update(dt)

    if not dialogue.active then
      self:cleanDialogue(dialogue)
    end
  end
end

function DialogueManager:keypressed(key)
  for _, dialogue in pairs(self.dialogues) do
    if key == "return" then
      dialogue:advance()
    end
  end
end