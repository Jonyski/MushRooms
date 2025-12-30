----------------------------------------
-- Classe Entity
----------------------------------------

---@class Entity
---@field name string
---@field pos Vec
---@field hb Hitbox
---@field room Room
Entity = {}
Entity.__index = Entity

function Entity:init(name, pos, hitbox, room)
    self.name = name or ""
    self.pos = pos
    self.hb = hitbox
    self.room = room
end
