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
	if el == nil then
		return
	end
	self.maxIndex = self.maxIndex + 1
	self[self.maxIndex] = el
	self.length = self.length + 1
end

function BiList:insertLeft(el)
	if el == nil then
		return
	end
	self.minIndex = self.minIndex - 1
	self[self.minIndex] = el
	self.length = self.length + 1
end

-- cuidado, esta função pode deixar buracos na lista
function BiList:insert(index, el)
	if el == nil then
		return
	end
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

function tableIndexOf(table, value)
	for i, v in ipairs(table) do
		if v == value then
			return i
		end
	end
	return nil
end

-- Retorna x limitado ao intervalo [a, b]
function clamp(x, a, b)
	if x < a then
		return a
	end
	if x > b then
		return b
	end
	return x
end

-- Função de interpolação linear
function lerp(a, b, t)
	return a + (b - a) * t
end

-- transforma uma string em um formato padronizado para caminhos
function pathlizeName(s)
	return string.lower(s:gsub(" ", "_"))
end

-- transforma uma lista de pastas e um nome de arquivo em um caminho para o arquivo
function pngPathFormat(parts)
	local path = ""
	for i, v in ipairs(parts) do
		if i ~= #parts then
			path = path .. pathlizeName(v) .. "/"
		else
			path = path .. pathlizeName(v) .. ".png"
		end
	end
	return path
end
