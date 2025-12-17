
require("modules.systems.dialogue.dialogue")

---@return Dialogue
-- cria um diálogo de teste com algumas falas simples
function npcTestDialogue()
  local list = {
    intro = {
      text = {
        "Olá, viajante.",
        "Faz tempo que não vejo alguém por aqui.",
        "Essas terras não são mais seguras como antes.",
        "Tenha cuidado."
      },
      triggered = false
    },
    met = {
      text = {
        "Já lhe disse para ter cuidado por aqui.",
        "Não é seguro andar sozinho."
      },
      triggered = nil,
    },
    -- diálogos especiais
    katana = {
      text = {
        "Vejo que você tem uma katana.",
        "Essas lâminas são forjadas com muita habilidade.",
        "Use-a bem."
      },
      triggered = false,
      condition = function(player)
        return player:hasWeapon(KATANA.name)
      end,
    },
    sling_shot = {
      text = {
        "Uma estilingue, hein?",
        "Boa para atacar inimigos de longe.",
        "Acerte bem seus tiros!"
      },
      triggered = false,
      condition = function(player)
        return player:hasWeapon(SLING_SHOT.name)
      end,
    },
  }
  
  return Dialogue.new(list)
end
