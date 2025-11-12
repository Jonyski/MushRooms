----------------------------------------
-- Classe Loot
----------------------------------------
Loot = {}
Loot.__index = Loot
Loot.type = "loot"

-- Um loot é efetivamente uma lista de items, chances e quantidades
function Loot.new(object, chance, amountRange, autoPick)
    local loot = setmetatable({}, Loot)
    loot.len = 0
    loot:add(object, chance, amountRange, autoPick)
    return loot
end

function Loot:add(object, chance, amountRange, autoPick)
    if not object then
        return
    end
    self.len = self.len + 1
    self[self.len] = {}
    self[self.len].object = object
    self[self.len].chance = chance
    self[self.len].amountRange = amountRange
    self[self.len].autoPick = autoPick
end

----------------------------------------
-- Tabela de loots do jogo
----------------------------------------
LOOT_TABLE = {
    barrel = Loot.new({ type = "coin", name = "coin" }, 0.5, range(1, 4), true),
    jar = Loot.new({ type = "coin", name = "coin" }, 0.5, range(1, 4), true),
}
