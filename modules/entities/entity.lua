----------------------------------------
-- Classe Entity
----------------------------------------

---@class Entity
---@field name string
---@field pos? Vec
---@field hb? Hitbox
---@field room? Room
---@field mass number
---@field friction number
---@field vel Vec
---@field acc Vec
Entity = {}
Entity.__index = Entity

---@param name string
---@param pos? Vec
---@param hitbox? Hitbox
---@param room? Room
---@param mass? number
---@param friction? number
-- inicializa uma entidade com propriedades básicas.
function Entity:init(name, pos, hitbox, room, mass, friction)
    self.name = name or ""
    self.pos = pos
    self.hb = hitbox
    self.room = room

    self.mass = mass or 1
    self.friction = friction or 5
    self.vel = vec(0, 0)
    self.acc = vec(0, 0)
end
