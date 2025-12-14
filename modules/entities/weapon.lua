----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.attacks")
require("modules.utils.shapes")
require("modules.engine.animation")
require("modules.utils.types")

----------------------------------------
-- Classe Weapon
----------------------------------------

---@class Weapon
---@field name string
---@field ammo number
---@field cooldown number
---@field atk Attack
---@field canShoot boolean
---@field timer number
---@field target any
---@field rotation rad
---@field state string
---@field spriteSheets table<string, table>
---@field animations table<string, Animation>

Weapon = {}
Weapon.__index = Weapon
Weapon.type = WEAPON

---@param name string
---@param ammo number
---@param cooldown number
---@param attack Attack
---@return Weapon
-- cria uma instância de `Weapon`
function Weapon.new(name, ammo, cooldown, attack)
	local weapon = setmetatable({}, Weapon)

	-- atributos que variam
	weapon.name = name -- nome do tipo de arma
	weapon.ammo = ammo -- número de munições
	weapon.cooldown = cooldown -- tempo de espera entre ataques consecutivos
	weapon.atk = attack -- instância de Attack associada à arma
	-- atributos fixos na instanciação
	weapon.canShoot = false
	weapon.timer = 0 -- timer do cooldown
	weapon.target = nil -- inimigo para o qual a arma está mirando
	weapon.rotation = 0 -- rotação da arma em radianos
	weapon.state = IDLE -- estado atual da arma
	weapon.spriteSheets = {} -- no tipo imagem do love
	weapon.animations = {} -- as chaves são estados e os valores são Animações
	return weapon
end

---@param dirVec Vec
-- atualiza a orientação (ângulo em radianos) de `Weapon`
function Weapon:updateOrientation(dirVec)
	if dirVec.x == 0 and dirVec.y == 0 then
		self.rotation = -math.pi * 0.5
	else
		self.rotation = math.atan2(dirVec.x, -dirVec.y) - math.pi * 0.5
	end
end

---@param idleSettings AnimSettings
---@param weaponAtkSettings AnimSettings
-- inicializa as animações de `Weapon` e as associa com seus respectivos estados
function Weapon:addAnimations(idleSettings, weaponAtkSettings)
	-- animação idle
	local path = pngPathFormat({ "assets", "animations", "weapons", self.name, IDLE })
	addAnimation(self, path, IDLE, idleSettings)
	-- animação da arma ao atacar
	path = pngPathFormat({ "assets", "animations", "weapons", self.name, ATTACKING })
	addAnimation(self, path, ATTACKING, weaponAtkSettings)
end

---@param dt number
-- atualiza o estado, o cooldown e o ataque da arma
function Weapon:update(dt)
	-- atualizando o cooldown
	if self.canShoot == false then
		self.timer = self.timer - dt
	end
	if self.timer < 0 then
		self.timer = self.cooldown
		self.canShoot = true
		self.state = IDLE
		self.animations[ATTACKING]:reset()
	end
	-- atualizando todos os ataques/eventos desferidos
	self.atk:update(dt)
end

----------------------------------------
-- Funções de Renderização
----------------------------------------

---@param camera Camera
-- renderiza a arma na perspectiva da `camera`
function Weapon:draw(camera)
	-- Não renderiza armas de jogadores se defendendo
	if self.owner.state == DEFENDING then
		return
	end
	local wViewPos = camera:viewPos(self.owner.pos)
	local animation = self.animations[self.state]
	local quad = animation.frames[animation.currFrame]
	-- inverte arma no segundo e terceiro quadrantes
	local flipY = (self.rotation / math.pi < -0.5 and self.rotation / math.pi >= -1.5) and -1 or 1

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(
		self.spriteSheets[self.state],
		quad,
		wViewPos.x,
		wViewPos.y,
		self.rotation,
		3,
		3 * flipY,
		animation.frameDim.width / 2 - 5,
		animation.frameDim.height / 2 - 5
	)
end
