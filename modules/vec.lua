----------------------------------------
-- Funções Utilitárias
----------------------------------------

function normalize(v)
    local mod = math.sqrt(math.pow(v.x, 2) + math.pow(v.y, 2))
    v.x = v.x / mod
    v.y = v.y / mod
end

function distance(v1, v2)
    return math.sqrt((v2.x - v1.x)^2 + (v2.y - v1.y)^2)
end

function midpoint(v1, v2)
    return { 
        x = (v1.x + v2.x) / 2, 
        y = (v1.y + v2.y) / 2 
    }
end

function nullVec(v)
    if v.x == 0 and v.y == 0 then
        return true
    else 
        return false
    end
end