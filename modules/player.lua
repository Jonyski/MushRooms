----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules/utils")
require("modules/animation")
require("modules/vec")
require("modules/particles")
require("modules/colors")
require("table")

----------------------------------------
-- Variáveis e Enums
----------------------------------------
players = {}

-- Cada estado está relacionado a uma animação do cogumelinho
IDLE = "idle"
WALKING_UP = "walking up"
WALKING_DOWN = "walking down"
WALKING_LEFT = "walking left"
WALKING_RIGHT = "walking right"
DEFENDING = "defending"
ATTACKING = "attacking"

----------------------------------------
-- Classe Player
----------------------------------------
Player = {}
Player.__index = Player

-- Construtor
function Player.new(id, name, spawn_pos, controls, colors, room)
	local player = setmetatable({}, Player)

	-- atributos que variam
	player.id = id -- número do jogador
	player.name = name -- nome do jogador
	player.hp = 10 -- pontos de vida
	player.pos = spawn_pos -- posição do jogador (inicializa para a posição do spawn)
	player.controls = controls -- os comandos para controlar o boneco, no formato {up = "", left = "", down = "", right = "", action = ""}
	player.colors = colors -- paleta de cores do jogador
	player.room = room -- sala na qual o jogador está atualmente
	-- atributos fixos na instanciação
	player.vel = 280 -- velocidade em pixels por segundo
	player.size = { height = 32, width = 32 } -- em pixels
	player.movementVec = { x = 0, y = 0 } -- vetor de direção e magnitude do movimento do jogador
	player.state = IDLE -- define o estado atual do jogador, estreitamente relacionado às animações
	player.spriteSheets = {} -- no tipo imagem do love
	player.animations = {} -- as chaves são estados e os valores são Animações
	player.particles = {} -- efeitos de partícula emitidos pelo player
	player.weapons = {} -- lista das armas que o jogador possui
	player.weapon = nil -- arma equipada
	return player
end

function Player:addAnimations()
	-- animação idle
	self:addAnimation(IDLE, 2, 0.5, true, 1)
	-- animação defesa
	self:addAnimation(DEFENDING, 15, 0.05, true, 12)
	-- animação andar para cima
	self:addAnimation(WALKING_UP, 4, 0.25, true, 1)
	-- animação andar para baixo
	self:addAnimation(WALKING_DOWN, 4, 0.25, true, 1)
	-- animação andar para esquerda
	self:addAnimation(WALKING_LEFT, 4, 0.25, true, 1)
	-- animação andar para direita
	self:addAnimation(WALKING_RIGHT, 4, 0.25, true, 1)
end

function Player:addAnimation(action, numFrames, frameDur, looping, loopFrame)
	local path = pngPathFormat({ "assets", "animations", "players", self.name, action })
	local quadSize = { width = 32, height = 32 }
	local animation = newAnimation(path, numFrames, quadSize, frameDur, looping, loopFrame, quadSize)
	self.animations[action] = animation
	self.spriteSheets[action] = love.graphics.newImage(path)
	self.spriteSheets[action]:setFilter("nearest", "nearest")
end

function Player:addParticles()
	-- Efeito de partícula do player se defendendo
	self.particles[DEFENDING] = newDefenseParticles(self.colors[1], self.colors[3])
end

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
	self:updateState()
	self:updateParticles(dt)
	self:checkColisions()
end

function Player:move(dt)
	self.movementVec = { x = 0, y = 0 }

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
	normalize(self.movementVec)
	-- Levando o dt e a velocidade do cogumelo em consideração
	self.movementVec.x = self.movementVec.x * dt * self.vel
	self.movementVec.y = self.movementVec.y * dt * self.vel
	self.pos.x = self.pos.x + self.movementVec.x
	self.pos.y = self.pos.y + self.movementVec.y

	if self.weapon then
		self.weapon:updateOrientation({ x = self.movementVec.x, y = self.movementVec.y })
	end
	self:updateRoom()
end

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

function Player:updateState()
	local prevState = self.state
	if love.keyboard.isDown(self.controls.act2) then
		-- só defende se está completamente parado; se não, muda de arma
		if nullVec(self.movementVec) then
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
	-- resetando a animação anterior, caso o estado tenha mudado
	if self.state ~= prevState then
		if prevState == DEFENDING then
			self.particles[DEFENDING]:stop()
		end
		self.animations[prevState]:reset()
	end
end

function Player:updateParticles(dt)
	self.particles[DEFENDING]:update(dt)
end

function Player:checkAction1(key)
	if key == self.controls.act1 then
		self:attack()
	end
end

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

function Player:collectWeapon(weapon)
	-- previne de pegar a mesma arma novamente
	if self:hasWeapon(weapon.name) then
		return false
	end

	table.insert(self.weapons, weapon)
	weapon.owner = self

	return true
end

function Player:equipWeapon(weaponName)
	-- itera pelas armas do jogador procurando pela que ele quer equipar
	for _, w in pairs(self.weapons) do
		if w.name == weaponName then
			self.weapon = w
		end
	end
end

function Player:hasWeapon(weaponName)
	for _, w in pairs(self.weapons) do
		if w.name == weaponName then
			return true
		end
	end

	return false
end

function Player:attack()
	if self.weapon and self.weapon.canShoot then
		self.weapon.atk:attack(self, self.pos, self.weapon.rotation)
		self.weapon.canShoot = false
		self.weapon.state = ATTACKING
	end
end

function Player:checkColisions()
	for _, d in pairs(self.room.destructibles) do
		local dist = dist(self.pos, d.pos)
		if d.state == INTACT and dist < (self.size.width / 2 + d.size.width / 2) then
			d:breakApart()
		end
	end
end

function Player:draw(camera)
	local viewPos = camera:viewPos(self.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	local offset = {
		x = animation.frameDim.width / 2,
		y = animation.frameDim.height / 2,
	}
	love.graphics.draw(self.spriteSheets[self.state], quad, viewPos.x, viewPos.y, 0, 3, 3, offset.x, offset.y)
	for _, v in pairs(self.particles) do
		love.graphics.draw(v, viewPos.x, viewPos.y)
	end
end

----------------------------------------
-- Funções Globais
----------------------------------------
function newPlayer()
	-- limite de jogadores alcançado
	if #players >= 4 then
		return false
	end

	if #players == 0 then
		-- o +365 e +350 são números mágicos para centralizar o player 1 na sala inicial
		local firstSpawnPoint = { x = window.width / 2 + 365, y = window.height / 2 + 350 }
		player1 = Player.new(
			1,
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
	elseif #players == 1 then
		player2 = Player.new(
			2,
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
	elseif #players == 2 then
		player3 = Player.new(
			3,
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
	else
		player4 = Player.new(
			4,
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
	newCamera()
end

return Player
