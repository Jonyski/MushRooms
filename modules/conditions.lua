conditionTable = {
  hasKatana = function (player)
    return player:hasWeapon(KATANA.name)
  end,
  hasSlingShot = function (player)
    return player:hasWeapon(SLING_SHOT.name)
  end,
}

function getCondition(key)
  return conditionTable[key] or function () return true end
end

