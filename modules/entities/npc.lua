----------------------------------------
-- Enums
----------------------------------------

-- comportamento dos NPCs após interagirem com o jogador
NOMAD = "nomad" -- desaparece
SEDENTARY = "sedentary" -- fica na sala onde spawnou indefinidamente
LOYAL = "loyal" -- vai para a base do jogador, caso ela exista

----------------------------------------
-- Classe Non-Playable Character
----------------------------------------

---@class Npc
---@field name string
---@field job string profissao
---@field personality any
---@field lifestyle string comportamento após interação com o jogador
---@field hb Hitbox
---@field room Room
---@field pos Vec
---@field inventory any 
---@field state string
---@field spriteSheets table<string, table>
---@field animation table<string, Animation>
---@field addAnimations function
---@field dialogue Dialogue
---@field inDialogue boolea

Npc = {}
Npc.__index = Npc
Npc.type = NPC

---@param description NpcDescription
---@param spawnPos Vec
---@param hitbox Hitbox 
---@param room Room 
---@return Npc 
function Npc.new(description, spawnPos, hitbox, room)
	local npc = setmetatable({}, Npc)

	-- atributos que variam
	npc.name = description.name -- nome do npc
	npc.job = description.job -- define a profissão do npc
	npc.personality = description.personality -- define a personalidade do npc
	npc.lifestyle = description.lifestyle -- define o inventário do npc
	npc.hb = hitbox -- hitbox do npc
	npc.pos = spawnPos -- posição do npc
	npc.room = room -- sala do npc
	-- atributos fixos na instanciação
	npc.inventory = {} -- define o inventário do npc
	npc.state = IDLE -- define o estado atual do npc, estreitamente relacionado às animações
	npc.spriteSheets = {} -- no tipo imagem do love
	npc.animations = {} -- as chaves são estados e os valores são Animações
	npc.dialogue = nil -- diálogo do npc
	npc.inDialogue = false -- se o npc está em diálogo

	table.insert(room.npcs, npc)
	return npc
end

---@class NpcDescription
---@field name string
---@field job string
---@field personality string
---@field lifestyle string

---@param name string
---@param job string
---@param personality string
---@param lifestyle string
function newNpcDescription(name, job, personality, lifestyle)
	return {
		name = name,
		job = job,
		personality = personality,
		lifestyle = lifestyle,
	}
end

---@param idleSettings AnimSettings
-- adiciona as animações dos estados dos npcs à sua tabela de animações
function Npc:addAnimations(idleSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "npcs", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)

	-- TODO: adicionar o resto das animações
end

---@param dt number
-- atualiza os estados do npc
function Npc:update(dt)
	self.animations[self.state]:update(dt)
end

---@param camera Camera
-- função de renderização de `Npc`
function Npc:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local offset = {
		x = animation.frameDim.width / 2,
		y = animation.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
end