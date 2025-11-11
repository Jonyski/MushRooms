----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.engine.animation")
require("modules.utils.utils")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------

INTACT = "intact"
BREAKING = "breaking"
BROKEN = "broken"

----------------------------------------
-- Tabela de loot: quais drops cada tipo de objeto pode gerar
----------------------------------------
LOOT_TABLE = {
    ["barrel"] = {
        { item = "coin", chance = 0.5, amount = { 1, 4 }, pickupType = "auto" },
    },

    ["jar"] = {
        { item = "coin", chance = 0.5, amount = { 1, 4 }, pickupType = "auto" },
    },
}

----------------------------------------
-- Classe Destructible
----------------------------------------
Destructible = {}
Destructible.__index = Destructible
Destructible.type = "destructible"

function Destructible.new(name, pos, room, loot)
    local obj = setmetatable({}, Destructible)

    obj.name = name                                                 -- nome do objeto
    obj.pos = { x = room.center.x + pos.x, y = room.center.y + pos.y } -- posição relativa ao centro da sala
    obj.room = room                                                 -- sala a qual pertence
    obj.state = INTACT
    obj.health = 100                                                -- vida para ser destruído
    obj.spriteSheets = {}
    obj.animations = {}
    obj.loot = loot or LOOT_TABLE[name] or {} -- pode ser sobrescrito na criação

    obj:addAnimations()
    table.insert(room.destructibles, obj)

    return obj
end

----------------------------------------
-- Animações
----------------------------------------
function Destructible:addAnimations()
    self:addAnimation(INTACT, 1, 1, true)
    self:addAnimation(BREAKING, 7, 0.05, false)
    self:addAnimation(BROKEN, 1, 1, true)
end

function Destructible:addAnimation(state, numFrames, frameDur, looping)
    local path = pngPathFormat({ "assets", "animations", "destructibles", self.name, state })
    local quadSize = { width = 64, height = 64 }
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
    rollLoot(self, self.pos) -- gera (ou não) loot ao quebrar

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
function newDestructible(name, pos, room, loot)
    return Destructible.new(name, pos, room, loot)
end

function rollLoot(object, pos)
    local lootTable = object.loot
    if not lootTable then
        return
    end -- retorna se não há nenhum loot definido

    for _, loot in pairs(lootTable) do
        if math.random() < loot.chance then
            local amount = loot.amount -- pode ser um número ou um table
            if type(amount) == "table" then
                -- se for um table, sorteia um valor entre amount[1] e amount[2]
                amount = math.random(amount[1], amount[2])
            end

            for i = 1, amount do
                -- items são criados a partir do centro da sala
                -- logo, é necessário converter 'pos' (absoluta) para relativa
                local itemPos = subVec(pos, object.room.center)

                local item = newItem(loot.item, {
                    x = itemPos.x,
                    y = itemPos.y,
                }, object.room, loot.pickupType, math.random(-20, 20))

                item:applyImpulse(math.random(-100, 100), -math.random(150, 200))
            end
        end
    end
end

return Destructible
