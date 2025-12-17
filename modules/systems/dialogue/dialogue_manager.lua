DialogueManager = {}
DialogueManager.current = nil
DialogueManager.context = {}

function DialogueManager.start(dialogue)
  if DialogueManager.current then
    return
  end

  DialogueManager.current = dialogue

  dialogue:start()
end

function DialogueManager.endDialogue()
  if DialogueManager.current then
    DialogueManager.current:endDialogue()
  end

  DialogueManager.current = nil
end

function DialogueManager.update(dt)
  if not DialogueManager.current then 
    return 
  end
  
  DialogueManager.current:update(dt)

  if not DialogueManager.current.active then
    DialogueManager.current = nil
  end
end

function DialogueManager.draw()
  if not DialogueManager.current then 
    return 
  end

  DialogueManager.current:draw(50, love.graphics.getHeight() - 120)
end

function DialogueManager.keypressed(key)
  if not DialogueManager.current then 
    return 
  end

  if key == "return" or key == "space" then
    DialogueManager.current:advance()
  end
end