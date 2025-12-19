----------------------------------------
-- Importações de Módulos
----------------------------------------
require("modules.systems.movement")

----------------------------------------
-- Construtores de Ataques
----------------------------------------
-- de forma semelhante ao que fizemos com o sistema de
-- movimentos, iremos utilizar o padrão de estratégia
-- para criar tipos de ataque reutilizáveis e ao mesmo
-- tempo altamente customizáveis, sendo que o trade-off
-- entre reutilizabilidade e customização pode ser
-- ajustado a gosto e com mínimos efeitos colaterais.
-- Cada construtor neste arquivo recebe como argumento
-- as "configurações" que devem ser customizáveis para
-- aquele tipo de ataque, o restante dos dados necessários
-- para a criação de um ataque serão fixos naquele
-- construtor, e portanto representam a "essência" daquele
-- tipo de ataque: a parte imutável

---@param ally boolean
---@param cooldown number
---@param speed number
---@param trajectoryFunc? MovementFunc
---@return Attack
-- um tiro de pedrinha
function newPebbleShotAttack(ally, cooldown, speed, trajectoryFunc)
	local hb = hitbox(Circle.new(15), vec(0, 0))
	local settings = newAtkSetting(ally, 15, 1.5, hb, cooldown, speed, -speed / 2, 0, 2)
	local anim = newAnimSetting(5, { width = 16, height = 16 }, 0.1, true, 1)
	local updateFunc = AttackEvent.baseUpdate
	local onHitFunc = function(e, t)
		print("Pebble Shot acertou um alvo")
	end

	return Attack.new("Pebble Shot", settings, anim, updateFunc, onHitFunc, trajectoryFunc)
end
