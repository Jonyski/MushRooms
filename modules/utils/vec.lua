----------------------------------------
-- Funções Utilitárias
----------------------------------------

-- constrói um vetor bidimensional
function vec(x, y)
	return { x = x, y = y }
end

-- retorna o ponto médio entre dois vetores
function midpoint(v1, v2)
	return {
		x = (v1.x + v2.x) / 2,
		y = (v1.y + v2.y) / 2,
	}
end

-- transforma um vetor v em um vetor unitário v'
function normalize(v)
	local vec = vec(v.x, v.y)

	local mod = math.sqrt(v.x ^ 2 + v.y ^ 2)
	vec.x = vec.x / mod
	vec.y = vec.y / mod

	return vec
end

-- checa se um vetor é nulo
function nullVec(v)
	if v.x == 0 and v.y == 0 then
		return true
	else
		return false
	end
end

-- soma dois vetores
function addVec(v1, v2)
	return vec(v1.x + v2.x, v1.y + v2.y)
end

-- subtração de dois vetores
function subVec(v1, v2)
	return vec(v1.x - v2.x, v1.y - v2.y)
end

-- escala um vetor v por um fator a
function scaleVec(v, a)
	return vec(v.x * a, v.y * a)
end

-- constrói um vetor a partir de coordenadas polares
function polarToVec(angle, r)
	return scaleVec(vec(math.cos(angle), math.sin(angle)), r)
end

-- retorna o tamanho/módulo de um vetor
function lenVec(v)
	return math.sqrt(v.x^2 + v.y^2)
end

-- retorna a distância de dois entre dois vetores
function dist(v1, v2)
	return lenVec(subVec(v1, v2))
end

-- produto escalar de dois vetores
function dotProd(v1, v2)
	return v1.x * v2.x + v1.y * v2.y
end

-- multiplica um vetor pela matriz de rotação, dado um ângulo em radianos
function rotateVec(v, angle)
	local cosA = math.cos(angle)
	local sinA = math.sin(angle)

	return vec(
		v.x * cosA - v.y * sinA,
		v.x * sinA + v.y * cosA
	)
end