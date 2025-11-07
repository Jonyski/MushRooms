----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

function hitbox(shape, pos)
    return { shape = shape, pos = pos }
end

----------------------------------------
-- Funções auxiliares para colisão
----------------------------------------

-- recebe duas hitboxes, retorna true se elas se tocam
function checkCollision(hb1, hb2)
    if hb1.shape.shape == "circle" then
        if hb2.shape.shape == "circle" then
            return checkCircleCircleCollision(hb1, hb2)
        elseif hb2.shape.shape == "rectangle" then
            return checkCircleRectCollision(hb1, hb2)
        elseif hb2.shape.shape == "line" then
            return checkCircleLineCollision(hb1, hb2)
        end
    elseif hb1.shape.shape == "rectangle" then
        if hb2.shape.shape == "circle" then
            return checkCircleRectCollision(hb2, hb1)
        elseif hb2.shape.shape == "rectangle" then
            return checkRectRectCollision(hb1, hb2)
        elseif hb2.shape.shape == "line" then
            return checkRectLineCollision(hb1, hb2)
        end
    elseif hb1.shape.shape == "line" then
        if hb2.shape.shape == "circle" then
            return checkCircleLineCollision(hb2, hb1)
        elseif hb2.shape.shape == "rectancle" then
            return checkRectLineCollision(hb2.hb1)
        elseif hb2.shape.shape == "line" then
            return checkLineLineCollision(hb1, hb2)
        end
    end

    return nil
end

function pointOnLine(point, line)
    local d1 = dist(point, line.pos)
    local d2 = dist(point, polarToVec(line.shape.angle, line.shape.length) + line.pos)
    local leniency = 0.01
    if d1 + d2 < line.shape.length + leniency and d1 + d2 > line.shape.length - leniency then
        return true
    end
    return false
end

function checkCircleCircleCollision(circle1, circle2)
    return dist(circle1.pos, circle2.pos) <= circle1.shape.radius + circle2.shape.radius
end

function checkCircleRectCollision(circle, rect)
    local rectCenter = vec(rect.pos.x + rect.shape.half_w, rect.pos.y + rect.shape.half_h)
    local dist = vec(abs(circle.pos.x - rectCenter.x), abs(circle.pos.y - rectCenter.y))
    if dist.x > (rect.shape.half_w + circle.shape.radius) or dist.y > (rect.shape.half_w + circle.shape.radius) then
        return false
    end
    if dist.x <= rect.shape.half_w or dist.y <= rect.shape.half_h then
        return true
    end
    local cornerDist = math.pow(dist.x - rect.shape.half_w, 2) + math.pow(dist.y - rect.shape.half_h, 2)
    return cornerDist <= pow(circle.shape.radius, 2)
end

function checkCircleLineCollision(circle, line)
    local p1 = line.pos
    local p2 = addVec(p1, polarToVec(line.shape.angle, line.shape.length))
    if dist(p1, circle.pos) < circle.shape.radius or dist(p2, circle.pos) < circle.shape.radius then
        return true
    end
    local dot = dotProd(subVec(circle.pos, p1), subVec(p2, p1))
    local closestX = p1.x + (dot * (p2.x - p1.x))
    local closestY = p1.y + (dot * (p2.y - p1.y))
    if not pointOnLine(vec(closestX, closestY), line) then
        return false
    end
    local distX = closestX - circle.pos.x
    local distY = closestY - circle.pos.y
    local dist = pow(distX, 2) + pow(distY, 2)
    if dist <= pow(circle.shape.radius, 2) then
        return true
    end
    return false
end

function checkRectRectCollision(rect1, rect2)
    if
        rect1.pos.x + rect1.shape.width >= rect2.pos.x
        and rect1.pos.x <= rect2.pos.x + rect2.shape.width
        and rect1.pos.y + rect1.shape.height >= rect2.pos.y
        and rect1.pos.y <= rect2.pos.y + rect2.shape.height
    then
        return true
    end
    return false
end

function checkRectLineCollision(rect, line)
    local leftSide = hitbox(Line.new(math.pi * 3 / 2, rect.shape.height), rect.pos)
    local upSide = hitbox(Line.new(0, rect.shape.width), rect.pos)
    local rightSide =
        hitbox(Line.new(math.pi * 3 / 2, rect.shape.height), addVec(rect.pos, scaleVec(vec(1, 0), rect.shape.width)))
    local downSide = hitbox(Line.new(0, rect.shape.width), addVec(rect.pos, scaleVec(vec(0, 1), rect.shape.height)))
    local leftHit = checkLineLineCollision(line, leftSide)
    local upHit = checkLineLineCollision(line, upSide)
    local rightHit = checkLineLineCollision(line, rightSide)
    local downHit = checkLineLineCollision(line, downSide)
    if leftHit or upHit or rightHit or downHit then
        return true
    end
    return false
end

function checkLineLineCollision(line1, line2)
    local p1 = line1.pos
    local p2 = addVec(p1, polarToVec(line1.shape.angle, line1.shape.length))
    local p3 = line2.pos
    local p4 = addVec(p3, polarToVec(line2.shape.angle, line2.shape.length))

    local a = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x))
        / ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
    local b = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x))
        / ((p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y))
    if a >= 0 and a <= 1 and b >= 0 and b <= 1 then
        return true
    end
    return false
end
