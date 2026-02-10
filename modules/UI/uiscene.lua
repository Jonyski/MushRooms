----------------------------------------
-- Enums
----------------------------------------

BG_LAYER_1 = 1
BG_LAYER_2 = 2
VISUAL_LAYER_1 = 3
VISUAL_LAYER_2 = 4
ELEM_LAYER = 5

----------------------------------------
-- Classe UIScene
----------------------------------------

UIScene = {}
UIScene.__index = UIScene
UIScene.type = UI_SCENE

function UIScene.new(sceneType, player)
	local uiscene = setmetatable({}, UIScene)
	uiscene.subtype = sceneType
	if player then
		uiscene.controls = player.controls
	else
		uiscene.controls = { up = "w", left = "a", down = "s", right = "d", act1 = "space", act2 = "lshift" }
	end
	uiscene.active = false
	uiscene.selectionPos = vec(1, 1)
	uiscene.layers = { {}, {}, {}, {}, {} }
	return uiscene
end

function UIScene:addElement(element, layer, pos)
	if not self.layers[layer][pos.y] then
		self.layers[layer][pos.y] = {}
	end
	self.layers[layer][pos.y][pos.x] = element
	-- o primeiro elemento começa selecionado
	if layer == ELEM_LAYER and pos.x == 1 and pos.y == 1 then
		self.layers[ELEM_LAYER][1][1]:select()
	end
	return self
end

function UIScene:removeElement(layer, pos)
	self.layers[layer][pos.y][pos.x] = nil
	return self
end

function UIScene:update(dt)
	for _, layer in pairs(self.layers) do
		for _, row in pairs(layer) do
			for _, el in pairs(row) do
				el:update(dt)
			end
		end
	end
end

function UIScene:draw()
	for _, layer in pairs(self.layers) do
		for _, row in pairs(layer) do
			for _, el in pairs(row) do
				el:draw()
			end
		end
	end
end

function UIScene:keypressed(key, isrepeat)
	local prevSelPos = vec(self.selectionPos.x, self.selectionPos.y)
	local elemLayer = self.layers[ELEM_LAYER]

	if key == self.controls.left then
		if self.selectionPos.x > 1 then
			self.selectionPos.x = self.selectionPos.x - 1
		end
	elseif key == self.controls.right then
		if self.selectionPos.x < #elemLayer[self.selectionPos.y] then
			self.selectionPos.x = self.selectionPos.x + 1
		end
	elseif key == self.controls.up then
		if self.selectionPos.y > 1 then
			local newY = self.selectionPos.y - 1
			local newX = 1
			if elemLayer[newY][self.selectionPos.x] then
				newX = self.selectionPos.x
			else
				newX = #elemLayer[newY]
			end
			self.selectionPos = vec(newX, newY)
		end
	elseif key == self.controls.down then
		if self.selectionPos.y < #elemLayer then
			local newY = self.selectionPos.y + 1
			local newX = 1
			if elemLayer[newY][self.selectionPos.x] then
				newX = self.selectionPos.x
			else
				newX = #elemLayer[newY]
			end
			self.selectionPos = vec(newX, newY)
		end
	elseif key == self.controls.act1 then
		local selPos = self.selectionPos
		local el = elemLayer[selPos.y][selPos.x]
		if el.subtype == UI_BUTTON_ELEM then
			el.onClick()
		end
	end

	if prevSelPos.y ~= self.selectionPos.y or prevSelPos.x ~= self.selectionPos.x then
		elemLayer[prevSelPos.y][prevSelPos.x]:deselect()
		elemLayer[self.selectionPos.y][self.selectionPos.x]:select()
	end
end
