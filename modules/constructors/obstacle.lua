----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.entities.obstacles")

function newPillar(spawnPos, room)
  local scale = 4
  local solidHb = hitbox(Circle.new(12*scale), vec(0, 12*scale))
  local triggerHb = hitbox(Rectangle.new(20*scale, 40*scale), vec(0, -8*scale))
  local hbs = hitboxes({ }, { solidHb }, { triggerHb })
  local obs = Obstacle.new(PILLAR.name, hbs, spawnPos, room, scale)

  return obs
end