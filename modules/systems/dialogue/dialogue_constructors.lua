
require("modules.systems.dialogue.dialogue")

---@return Dialogue
-- cria um diálogo de teste com algumas falas simples
function npcTestDialogue(npc)
  local graph = {
    nodes = {
      intro = {
        id = "intro",
        text = "Olá, viajante.",
        next = "line2"
      },

      line2 = {
        id = "line2",
        text = "Faz tempo que não vejo alguém por aqui.",
        next = "line3"
      },

      line3 = {
        id = "line3",
        text = "Essas terras não são mais seguras como antes.",
        next = "line4"
      },

      line4 = {
        id = "line4",
        text = "Tenha cuidado.",
        next = nil
      }
    },
    start = "intro",
  }
  
  return Dialogue.new(graph, { npc = npc })
end
