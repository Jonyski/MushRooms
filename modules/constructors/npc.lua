----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.constructors.dialogue")
require("modules.entities.npc")

---@param spawnPos Vec
---@param room Room
---@return Npc
--Cria Glob, a minhoca mágica
function initGlob(spawnPos, room)
	local hitbox = hitbox(Circle.new(130), spawnPos, NPC, TRIGGER)
	description = newNpcDescription(GLOB.name, "Magician", "Misterious", SEDENTARY)
	npc = Npc.new(description, spawnPos, hitbox, room)
	local idleAnimSettings = newAnimSetting(1, { width = 32, height = 32 }, 0.15, true, 1)
	npc:addAnimations(idleAnimSettings)
	npc.dialogue = globDialogue()
	return npc
end
