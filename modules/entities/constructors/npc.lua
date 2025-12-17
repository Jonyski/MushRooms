----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.npc")
require("modules.systems.dialogue.dialogue_constructors")

---@param spawnPos Vec
---@param room Room
---@return Npc
--Cria Glob, a minhoca mágica
function initGlob(spawnPos, room)
	local hitbox = hitbox(Circle.new(32), spawnPos)
	description = newNpcDescription(GLOB.name, "Magician", "Misterious", SEDENTARY)
	npc = Npc.new(description, spawnPos, hitbox, room)
	local idleAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.15, true, 1)
	npc:addAnimations(idleAnimSettings)
	npc.dialogue = npcTestDialogue(npc)
	return npc
end