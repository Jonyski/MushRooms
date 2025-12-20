----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.utils.utils")
require("modules.engine.animation")
require("modules.utils.vec")
require("modules.systems.particles")
require("modules.utils.colors")
require("modules.utils.types")
require("modules.utils.states")
require("modules.utils.shapes")
require("modules.utils.constructors")
require("modules.engine.collision")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------

players = {}

----------------------------------------
-- Classe Player
----------------------------------------

---@class Player
---@field id number
---@field name string
---@field hp number
---@field pos Vec
---@field controls table<string, string>
---@field colors Color[]
---@field room Room
---@field speed number
---@field size Size
---@field movementVec Vec
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>
---@field particles table<string, ParticleSystem>
---@field weapons table[]
---@field weapon table
---@field hb Hitbox
---@field invulnerableTimer number
---@field blinkTimer number
---@field addAnimations function
---@field addParticles function

Player = {}
Player.__index = Player
Player.type = PLAYER

---@param name string
---@param spawn_pos Vec
---@param controls table<string, string>
---@param colors Color[]
---@param room Room
---@return Player
-- cria uma instância de `Player` e o adiciona à lista global de `players`
function Player.new(name, spawn_pos, controls, colors, room)
	local player = setmetatable({}, Player)

	-- atributos que variam
	player.id = #players + 1                    -- número do jogador
	player.name = name                          -- nome do jogador
	player.hp = 100                             -- pontos de vida
	player.pos = spawn_pos                      -- posição do jogador (inicializa para a posição do spawn)
	player.controls =
	controls                                    -- os comandos para controlar o boneco, no formato {up = "", left = "", down = "", right = "", action = ""}
	player.colors = colors                      -- paleta de cores do jogador
	player.room = room                          -- sala na qual o jogador está atualmente
	-- atributos fixos na instanciação
	player.speed = 360                          -- velocidade em pixels por segundo
	player.size = { height = 32, width = 32 }   -- em pixels
	player.movementVec = { x = 0, y = 0 }       -- vetor de direção e magnitude do movimento do jogador
	player.state = IDLE                         -- define o estado atual do jogador, estreitamente relacionado às animações
	player.spriteSheets = {}                    -- no tipo imagem do love
	player.animations = {}                      -- as chaves são estados e os valores são Animações
	player.particles = {}                       -- efeitos de partícula emitidos pelo player
	player.weapons = {}                         -- lista das armas que o jogador possui
	player.weapon = nil                         -- arma equipada
	player.hb = hitbox(Circle.new(20), player.pos) -- hitbox do player
	player.invulnerableTimer = 0                -- timer de invulnerabilidade após levar dano
	player.blinkTimer = 0                       -- timer para piscar o sprite do player quando invulnerável

	collisionManager.players[player] = player.hb
	return player
end

---@param idleSettings AnimSettings
---@param defSettings AnimSettings
---@param WalkSettings AnimSettings
-- adiciona animações à tabela do `Player`, associando-as aos seus estados respectivos
function Player:addAnimations(idleSettings, defSettings, WalkSettings)
	----------------- IDLE -----------------
	local path = pngPathFormat({ "assets", "animations", "players", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	--------------- DEFENDING --------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, DEFENDING })
	addAnimation(self, path, DEFENDING, defSettings)
	-------------- WALKING UP --------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_UP })
	addAnimation(self, path, WALKING_UP, WalkSettings)
	------------- WALKING DOWN -------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_DOWN })
	addAnimation(self, path, WALKING_DOWN, WalkSettings)
	------------- WALKING LEFT -------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_LEFT })
	addAnimation(self, path, WALKING_LEFT, WalkSettings)
	------------- WALKING RIGHT ------------
	path = pngPathFormat({ "assets", "animations", "players", self.name, WALKING_RIGHT })
	addAnimation(self, path, WALKING_RIGHT, WalkSettings)
end

-- adiciona os efeitos de partícula à tabela do `Player`,
-- associando-os aos seus estados respectivos
function Player:addParticles()
	-- Efeito de partícula do player se defendendo
	self.particles[DEFENDING] = newDefenseParticles(self.colors[1], self.colors[3])
	-- Efeito de partícula do player caminhando
	local walkingParticles = newWalkingParticles()
	self.particles[WALKING_DOWN] = walkingParticles
	self.particles[WALKING_UP] = walkingParticles
	self.particles[WALKING_LEFT] = walkingParticles
	self.particles[WALKING_RIGHT] = walkingParticles
end

---@param dt number
-- atualiza o estado do `Player` de suas animações e efeitos de partícula
function Player:update(dt)
	self:move(dt)
	self.animations[self.state]:update(dt)
	for _, w in pairs(self.weapons) do
		-- atualizando a animação da arma equipada
		if w == self.weapon then
			self.weapon.animations[self.weapon.state]:update(dt)
		end
		w:update(dt)
	end
	if self.invulnerableTimer > 0 then
		self.invulnerableTimer = self.invulnerableTimer - dt
		self.blinkTimer = (self.blinkTimer + dt * 10) % 1
	end
	self:updateState()
	self:updateParticles(dt)
end

---@param dt number
-- movimenta o `Player` de acordo com o input do jogador
function Player:move(dt)
	self.movementVec = vec(0, 0)

	if self.state == DEFENDING then
		return
	end
	if love.keyboard.isDown(self.controls.up) then
		self.movementVec.y = -1
	end
	if love.keyboard.isDown(self.controls.down) then
		self.movementVec.y = 1
	end
	if love.keyboard.isDown(self.controls.left) then
		self.movementVec.x = -1
	end
	if love.keyboard.isDown(self.controls.right) then
		self.movementVec.x = 1
	end

	if self.movementVec.x == 0 and self.movementVec.y == 0 then
		return
	end

	-- Normalizando para impedir movimentos na diagonal de serem mais rápidos
	self.movementVec = normalize(self.movementVec)
	-- Levando o dt e a velocidade do cogumelo em consideração
	self.movementVec = scaleVec(self.movementVec, dt * self.speed)

	------------ HACK PARA DEBUG ------------
	if love.keyboard.isDown("lctrl") then
		self.movementVec = scaleVec(self.movementVec, 5)
	end
	-----------------------------------------

	setPos(self, addVec(self.pos, self.movementVec))

	self:updateParticlesPos()
	if self.weapon then
		self.weapon:updateOrientation({ x = self.movementVec.x, y = self.movementVec.y })
	end
	self:updateRoom()
end

-- redefine a sala atual onde o `Player` se encontra
function Player:updateRoom()
	local roomX = self.room.pos.x
	local roomY = self.room.pos.y
	local prevRoom = self.room

	-- o jogador foi para a sala à esquerda
	if self.pos.x < self.room.hitbox.p1.x then
		self.room = rooms[roomY][roomX - 1]
	end
	-- o jogador foi para a sala à direita
	if self.pos.x > self.room.hitbox.p2.x then
		self.room = rooms[roomY][roomX + 1]
	end
	-- o jogador foi para a sala acima
	if self.pos.y < self.room.hitbox.p1.y then
		self.room = rooms[roomY - 1][roomX]
	end
	-- o jogador foi para a sala abaixo
	if self.pos.y > self.room.hitbox.p2.y then
		self.room = rooms[roomY + 1][roomX]
	end

	-- se mudou de sala, se retira dela e entra na próxima
	if prevRoom ~= self.room then
		prevRoom.playersInRoom:remove(self.id)
		prevRoom:verifyIsEmpty()

		self.room:setExplored()
		self.room:visit(self)
	end
end

-- atualiza o estado do `Player`
function Player:updateState()
	local prevState = self.state
	local isMoving = not nullVec(self.movementVec)
	if love.keyboard.isDown(self.controls.act2) then
		-- só defende se está completamente parado; se não, muda de arma
		if not isMoving then
			if prevState ~= DEFENDING then
				self.particles[DEFENDING]:start()
			end
			self.state = DEFENDING
		end
	else
		if self.movementVec.y < 0 then
			self.state = WALKING_UP
		elseif self.movementVec.x > 0 then
			self.state = WALKING_RIGHT
		elseif self.movementVec.x < 0 then
			self.state = WALKING_LEFT
		elseif self.movementVec.y > 0 then
			self.state = WALKING_DOWN
		else
			self.state = IDLE
		end
	end

	-- atualizando a situação do sistema de partículas de caminhada
	if isMoving then
		self.particles[self.state]:setDirection(math.atan2(self.movementVec.y, self.movementVec.x) + math.pi)
		self.particles[self.state]:start()
	else
		self.particles[WALKING_UP]:stop()
	end

	-- resetando a animação anterior, caso o estado tenha mudado
	if self.state ~= prevState then
		if prevState == DEFENDING then
			self.particles[DEFENDING]:stop()
		end
		self.animations[prevState]:reset()
	end
end

---@param dt number
-- atualiza os efeitos de partícula do `Player`
function Player:updateParticles(dt)
	self.particles[DEFENDING]:update(dt)
	-- atualiza as partículas de caminhada como um todo
	self.particles[WALKING_UP]:update(dt)
end

-- atualiza as posições dos efeitos de partícula do `Player`
function Player:updateParticlesPos()
	self.particles[DEFENDING]:setPosition(self.pos.x, self.pos.y)
	self.particles[WALKING_UP]:setPosition(self.pos.x, self.pos.y + 24)
end

---@param key string
-- verifica se o `Player` está pressionando a tecla de ação 1,
-- caso positivo, chama a função de ataque dele
function Player:checkAction1(key)
	if key == self.controls.act1 then
		if self.weapon then
			self.weapon:attack()
		end
	end
end

---@param key string
-- verifica se o `Player` está pressionando a tecla de ação 2
-- caso positivo, executa a ação correta dependendo do contexto
function Player:checkAction2(key)
	if key == self.controls.act2 and self.movementVec.x ~= 0 then
		local len = #self.weapons
		if len <= 1 then
			return
		end
		local indexWeapon = tableIndexOf(self.weapons, self.weapon)
		local nextIndex = indexWeapon
		-- caminha ciclicamente entre as armas
		if self.movementVec.x > 0 then
			nextIndex = (indexWeapon % len) + 1
		else
			nextIndex = ((indexWeapon - 2 + len) % len) + 1
		end

		self:equipWeapon(self.weapons[nextIndex].name)
	end
end

---@param weapon any
---@return boolean
-- adiciona uma arma ao arsenal do `Player` caso ele não a tenha
function Player:collectWeapon(weapon)
	-- previne de pegar a mesma arma novamente
	if self:hasWeapon(weapon.name) then
		return false
	end
	table.insert(self.weapons, weapon)
	weapon.owner = self
	return true
end

---@param weaponName string
-- equipa uma arma com nome `weaponName` caso o `Player` a tenha
function Player:equipWeapon(weaponName)
	for _, w in pairs(self.weapons) do
		if w.name == weaponName then
			self.weapon = w
		end
	end
end

---@param weaponName string
---@return boolean
-- verifica se o `Player` possui uma arma com nome `weaponName`
function Player:hasWeapon(weaponName)
	for _, w in pairs(self.weapons) do
		if w.name == weaponName then
			return true
		end
	end
	return false
end

---@return boolean
-- coleta uma moeda; função não séria
function Player:collectCoin()
	print("moedinhaaa")
	return true
end

---@param item Item
-- coleta um item e o marca como coletado
function Player:collectItem(item)
	local result = false
	if item.object.type == WEAPON then
		result = self:collectWeapon(item.object)
		if result then
			self:equipWeapon(item.object.name)
		end
	elseif item.object.type == ITEM then
		result = self:collectCoin()
	end
	if result then
		item:setCollected()
	end
end

---@param item Item
-- verifica se condições-chave para a coleta de um item
-- são verdadeiras, caso positivo, coleta o item
function Player:tryCollectItem(item)
	if not item.canPick then
		return
	end
	if item.autoPick then
		self:collectItem(item)
		return
	elseif love.keyboard.isDown(self.controls.act2) then
		self:collectItem(item)
		return
	end
end

---@param camera Camera
-- renderiza o `Player` na perspectiva da `camera`
function Player:draw(camera)
	-- desenhando o efeito de partículas de caminhada atrás do player
	local particles_offset = {
		x = -camera.cx + camera.viewport.width / 2,
		y = -camera.cy + camera.viewport.height / 2,
	}
	love.graphics.draw(self.particles[WALKING_UP], particles_offset.x, particles_offset.y)

	if self.invulnerableTimer > 0 and self.blinkTimer <= 0.5 then
		return
	end
	-- desenhando o player em si
	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local offset = {
		x = animation.frameDim.width / 2,
		y = animation.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)

	-- desenhando o efeito de partículas da defesa em cima do player
	love.graphics.draw(self.particles[DEFENDING], particles_offset.x, particles_offset.y)
end

----------------------------------------
-- Funções Globais
----------------------------------------

---@return boolean?
-- inicializa o próximo jogador, caso os 4 jogadores
-- já tenham sido inicializados, retorna `false`
function newPlayer()
	-- limite de jogadores alcançado
	if #players >= 4 then
		return false
	end
	CONSTRUCTORS[PLAYER][#players + 1]()
	newCamera(players[#players])
end

return Player
