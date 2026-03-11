require("modules.entities.resources")

---@return Resource
-- cria um recurso do tipo Madeira
function newWood()
  local description = "A piece of wood, useful for crafting."
  local weight = 1.0
  local wood = Resource.new(WOOD.name, description, weight)

  return wood
end


---@return Resource
-- cria um recurso do tipo Pedra
function newStone()
  local description = "A sturdy stone, can be used for building."
  local weight = 2.0
  local stone = Resource.new(STONE.name, description, weight)

  return stone
end

---@return Resource
-- cria um recurso do tipo Osso
function newBone()
  local description = "A bone from a creature, might have some value."
  local weight = 0.5
  local bone = Resource.new(BONE.name, description, weight)

  return bone
end

---@return Resource
-- cria um recurso do tipo Pena
function newFeather()
  local description = "A light feather, could be used for crafting arrows."
  local weight = 0.2
  local feather = Resource.new(FEATHER.name, description, weight)

  return feather
end

---@return Resource
-- cria um recurso do tipo Ferro
function newIron()
  local description = "A chunk of iron ore, essential for forging weapons."
  local weight = 3.0
  local iron = Resource.new(IRON.name, description, weight)

  return iron
end

---@return Resource
-- cria um recurso do tipo Ouro
function newGold()
  local description = "A precious piece of gold, valuable for trading."
  local weight = 2.5
  local gold = Resource.new(GOLD.name, description, weight)

  return gold
end

---@return Resource
-- cria um recurso do tipo Pão
function newBread()
  local description = "A loaf of bread, restores a small amount of health."
  local weight = 0.8
  local bread = Resource.new(BREAD.name, description, weight)

  return bread
end