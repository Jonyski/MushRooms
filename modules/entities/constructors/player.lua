function initPlayer1()
    local firstSpawnPoint = { x = rooms[0][0].center.x, y = rooms[0][0].center.y }
    player1 = Player.new(
        "Mush",
        firstSpawnPoint,
        { up = "w", left = "a", down = "s", right = "d", act1 = "space", act2 = "lshift" },
        getP1ColorPalette(),
        rooms[0][0]
    )
    player1:addAnimations()
    player1:addParticles()
    player1.room:visit(player1)
    table.insert(players, player1)
end

function initPlayer2()
    local player2 = Player.new(
        "Shroom",
        { x = player1.pos.x + 75, y = player1.pos.y },
        { up = "up", left = "left", down = "down", right = "right", act1 = "rctrl", act2 = "rshift" },
        getP2ColorPalette(),
        players[1].room
    )
    player2:addAnimations()
    player2:addParticles()
    player2.room:visit(player2)
    table.insert(players, player2)
end

function initPlayer3()
    local player3 = Player.new(
        "Musho",
        { x = player1.pos.x + 75, y = player1.pos.y },
        { up = "t", left = "f", down = "g", right = "h", act1 = "r", act2 = "y" },
        getP3ColorPalette(),
        players[1].room
    )
    player3:addAnimations()
    player3:addParticles()
    player3.room:visit(player3)
    table.insert(players, player3)
end

function initPlayer4()
    local player4 = Player.new(
        "Roomy",
        { x = player1.pos.x + 75, y = player1.pos.y },
        { up = "i", left = "j", down = "k", right = "l", act1 = "u", act2 = "o" },
        getP4ColorPalette(),
        players[1].room
    )
    player4:addAnimations()
    player4:addParticles()
    player4.room:visit(player4)
    table.insert(players, player4)
end
