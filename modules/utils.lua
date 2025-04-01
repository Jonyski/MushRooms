----------------------------------------
-- Enums Utilitários
----------------------------------------

-- direções
UP         = 0
UP_RIGHT   = 1
RIGHT      = 2
DOWN_RIGHT = 3
DOWN       = 4
DOWN_LEFT  = 5
LEFT       = 6
UP_LEFT    = 7

-- estados de personagem
IDLE = "idle"
WALKING = "walking"
DEFENDING = "defending"
ATTACKING = "attacking"

----------------------------------------
-- Classes Utilitárias
----------------------------------------
BiList = {}
BiList.__index = BiList

function BiList.new()
	local biList = setmetatable({}, BiList)
	biList.minIndex = 0
	biList.maxIndex = -1
	biList.length = 0
	return biList
end

function BiList:insertRight(el)
	if el == nil then return end
	self.maxIndex = self.maxIndex + 1
	self[self.maxIndex] = el
	self.length = self.length + 1
end

function BiList:insertLeft(el)
	if el == nil then return end
	self.minIndex = self.minIndex - 1
	self[self.minIndex] = el
	self.length = self.length + 1
end

-- cuidado, esta função pode doixar buracos na lista
function BiList:insert(index, el)
	if el == nil then return end
	self[index] = el
	if index > self.maxIndex then
		self.maxIndex = index
	elseif index < self.minIndex then
		self.minIndex = index
	end
	self.length = self.length + 1
end


----------------------------------------
-- Funções Utilitárias
----------------------------------------

function tableFind(table, value)
	for k, v in pairs(table) do
		if v == value then
			return k
		end
	end
	return nil
end