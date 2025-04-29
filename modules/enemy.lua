----------------------------------------
-- Classe Enemy
----------------------------------------
Enemy = {}
Enemy.__index = Enemy

function Enemy.new(name, spawnPos, color, move, attack)
	local enemy = setmetatable({}, Enemy)
	
	-- atributos que variam
	enemy.name = name     -- nome do inimigo
	enemy.pos = spawnPos  -- posição do inimigo
	enemy.color = color   -- cor do inimigo
	enemy.move = move     -- função de movimento do inimigo
	enemy.attack = attack -- função de ataque do inimigo
	-- atributos fixos na instanciação
	enemy.movementDirections = {} -- tabela com as direções de movimento atualmente ativas
	enemy.state = IDLE            -- define o estado atual do inimigo, estreitamente relacionado às animações
	enemy.spriteSheets = {}       -- no tipo imagem do love
	enemy.animations = {}         -- as chaves são estados e os valores são Animações

	return enemy
end

----------------------------------------
-- Funções Globais
----------------------------------------
