----------------------------------------
-- Módulo de Easing
----------------------------------------
Easing = {}

-- Linear
function Easing.linear(t) return t end

-- Quadratic
function Easing.inQuad(t) return t * t end
function Easing.outQuad(t) return t * (2 - t) end
function Easing.inOutQuad(t) 
	t = t * 2
	if t < 1 then return 0.5 * t * t end
	return -0.5 * ((t - 1) * (t - 3) - 1)
end

-- Cubic
function Easing.inCubic(t) return t * t * t end
function Easing.outCubic(t) 
	t = t - 1
	return t * t * t + 1 
end
function Easing.inOutCubic(t)
	t = t * 2
	if t < 1 then return 0.5 * t * t * t end
	t = t - 2
	return 0.5 * (t * t * t + 2)
end

-- Quartic
function Easing.inQuart(t) return t * t * t * t end
function Easing.outQuart(t)
	t = t - 1
	return -(t * t * t * t - 1)
end
function Easing.inOutQuart(t)
  return t < 0.5 and 8 * t * t * t * t or 1 - ((-2 * t + 2) ^ 4) / 2
end

-- Quintic
function Easing.inQuint(t) return t * t * t * t * t end
function Easing.outQuint(t)
	t = t - 1
	return (t * t * t * t * t + 1)
end

-- Back
function Easing.outBack(t)
  local c1 = 1.70158;
  local c3 = c1 + 1;

  return 1 + c3 * ((t - 1) ^ 3) + c1 * ((t - 1) ^ 2);

end

return Easing
