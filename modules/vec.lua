----------------------------------------
-- Funções Utilitárias
----------------------------------------

function normalize(v)
    local mod = math.sqrt(math.pow(v.x, 2) + math.pow(v.y, 2))
    v.x = v.x / mod
    v.y = v.y / mod
end
