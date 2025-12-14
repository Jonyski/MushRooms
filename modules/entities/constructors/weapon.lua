---@return Weapon
-- cria uma arma do tipo Katana
function newKatana()
	-- configurações do ataque
	local updateFunc = function(dt, atkEvent)
		atkEvent:baseUpdate(dt)
		-- seguindo o jogador
		atkEvent.pos = atkEvent.attacker.pos
	end
	local onHitFunc = function(atkEvent, target)
		print("Katana acertou um " .. target.type .. " por " .. atkEvent.dmg .. " de dano!")
		target.hp = target.hp - atkEvent.dmg
	end
	local hb = hitbox(Circle.new(100), vec(0, 0))
	local atkSettings = newBaseAtkSetting(true, 15, 0.5, hb)
	local atkAnimSettings = newAnimSetting(12, { width = 64, height = 64 }, 0.03, false, 1)
	local attack = Attack.new("Katana Slice", atkSettings, atkAnimSettings, updateFunc, onHitFunc)

	-- Inicialicação da arma em si
	local katana = Weapon.new(KATANA.name, math.huge, 0.3, attack)
	local idleAnimSettings = newAnimSetting(4, { width = 64, height = 64 }, 0.3, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(12, { width = 64, height = 64 }, 0.03, false, 1)
	katana:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return katana
end

---@return Weapon
-- cria uma arma do tipo Estilingue
function newSlingShot()
	-- configurações do ataque
	local updateFunc = function(dt, atkEvent)
		atkEvent:baseUpdate(dt)
	end
	local onHitFunc = function(atkEvent, target)
		print("Estilingue acertou um " .. target.type .. " por " .. atkEvent.dmg .. " de dano!")
		target.hp = target.hp - atkEvent.dmg
	end
	local hb = hitbox(Circle.new(15), vec(0, 0))
	local baseAtkSettings = newBaseAtkSetting(true, 15, 1.5, hb)
	local atkSettings = newProjectileAtkSetting(baseAtkSettings, 30, -15, 0, 2)
	local atkAnimSettings = newAnimSetting(5, { width = 16, height = 16 }, 0.1, true, 1)
	local attack = Attack.new("Pebble Shot", atkSettings, atkAnimSettings, updateFunc, onHitFunc)

	-- Inicialicação da arma em si
	local slingshot = Weapon.new(SLING_SHOT.name, math.huge, 0.4, attack)
	local idleAnimSettings = newAnimSetting(2, { width = 64, height = 64 }, 0.5, true, 1)
	local weaponAtkAnimSettings = newAnimSetting(10, { width = 64, height = 64 }, 0.05, false, 1)
	slingshot:addAnimations(idleAnimSettings, weaponAtkAnimSettings)
	return slingshot
end
