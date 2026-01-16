----------------------------------------
-- Classe Resource
----------------------------------------

---@class Resource
---@field name string
---@field weight number
---@field description string
---@field stack? boolean
---@field path string

Resource = {}
Resource.__index = Resource
Resource.type = RESOURCE

---@param name string
---@param description string
---@param weight number
---@param stack? boolean
-- cria uma nova instância de Resource
function Resource.new(name, description, weight, stack)
  ---@type Resource
  local resource = setmetatable({}, Resource) ---@diagnostic disable-line

  resource.name = name -- nome do recurso
  resource.weight = weight -- peso do recurso
  resource.description = description -- descrição do recurso
  resource.stack = (stack ~= false) -- se o recurso pode ser empilhado
  resource.path = pngPathFormat({ "assets", "sprites", "resources", name })

  return resource
end