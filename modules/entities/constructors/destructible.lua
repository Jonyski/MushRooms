function newBarrel(pos, room)
    local loot = Loot.new(newSlingShot(), 0.2, range(1, 1), false)
    loot:insert(newKatana(), 0.2, range(1, 1), false)
    loot:insert(COIN, 0.6, range(1, 5), true)
    local hitbox = hitbox(Rectangle.new(40, 60), pos)
    return Destructible.new(BARREL.name, pos, room, loot, hitbox)
end

function newJar(pos, room)
    local loot = Loot.new(COIN, 0.8, range(1, 3), true)
    local hitbox = hitbox(Circle.new(10), pos)
    return Destructible.new(JAR.name, pos, room, loot, hitbox)
end
