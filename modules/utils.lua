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

----------------------------------------
-- Funções Utilitárias
----------------------------------------

function tableFind(table, value)
	print(value)
	for k, v in pairs(table) do
		if v == value then
			print(k)
			return k
		end
	end
	return nil
end