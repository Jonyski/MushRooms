----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules/animation")
require("modules/utils")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------
-- destructibles = {}

INTACT = "intact"
BREAKING = "breaking"
BROKEN = "broken"

----------------------------------------
-- Classe Destructible
----------------------------------------
Destructible = {}
Destructible.__index = Destructible

-- Construtor
function Destructible.new(typeName, pos, room)
    local obj = setmetatable({}, Destructible)
    local centerRoom = midpoint(room.hitbox.p1, room.hitbox.p2)

    obj.type = typeName
    obj.pos = { x = centerRoom.x + pos.x, y = centerRoom.y + pos.y } -- posiciona relativo ao centro da sala
    obj.room = room
    obj.state = INTACT
    obj.health = 100
    obj.spriteSheets = {}
    obj.animations = {}
    obj.size = { width = 64, height = 64 }

    obj:addAnimations()
    table.insert(room.destructibles, obj)

    return obj
end

----------------------------------------
-- Animações
----------------------------------------
function Destructible:addAnimations()
  
  self:addAnimation(INTACT, 1, 1, true)
  self:addAnimation(BREAKING, 7, 0.1, false)
  self:addAnimation(BROKEN, 1, 1, true)
end

function Destructible:addAnimation(state, numFrames, frameDur, looping)
  local path = "assets/animations/destructibles/" .. string.lower(self.type) .. "/" .. state:gsub(" ", "_") .. ".png"
  local quadSize = { width = self.size.width, height = self.size.height }
  local animation = newAnimation(path, numFrames, quadSize, frameDur, looping, 1, quadSize)
  self.animations[state] = animation
  self.spriteSheets[state] = love.graphics.newImage(path)
  self.spriteSheets[state]:setFilter("nearest", "nearest")
end

----------------------------------------
-- Lógica de dano e destruição
----------------------------------------
function Destructible:damage(amount)
    if self.state == BROKEN or self.state == BREAKING then
        return
    end

    self.health = self.health - amount
    if self.health <= 0 then
        self:breakApart()
    end
end

function Destructible:breakApart()
    self.state = BREAKING
    local anim = self.animations[BREAKING]
    anim.onFinish = function()
        self.state = BROKEN
    end
end

----------------------------------------
-- Atualização
----------------------------------------
function Destructible:update(dt)
    self.animations[self.state]:update(dt)
end

----------------------------------------
-- Desenho
----------------------------------------
function Destructible:draw(camera)
    -- if self.state == BROKEN then return end
    local viewPos = camera:viewPos(self.pos)
    local anim = self.animations[self.state]
    local quad = anim.frames[anim.currFrame]
    local offset = {
        x = anim.frameDim.width / 2,
        y = anim.frameDim.height / 2,
    }
    love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
end

----------------------------------------
-- Função global auxiliar
----------------------------------------
function newDestructible(typeName, pos, room)
    return Destructible.new(typeName, pos, room)
end

return Destructible