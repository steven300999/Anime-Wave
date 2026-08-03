extends RefCounted
class_name BulletPatterns

static func radial(count: int, gap_index: int = -1) -> Array[float]:
	var angles: Array[float] = []
	if count <= 0:
		return angles
	for i in count:
		if i == gap_index:
			continue
		angles.append(float(i) / float(count) * TAU)
	return angles

static func aimed_volley(base_angle: float, count: int, spread: float) -> Array[float]:
	var angles: Array[float] = []
	if count <= 0:
		return angles
	if count == 1:
		angles.append(base_angle)
		return angles
	for i in count:
		var t := float(i) / float(count - 1) - 0.5
		angles.append(base_angle + t * spread)
	return angles

static func spiral(base_angle: float, count: int, step: float) -> Array[float]:
	var angles: Array[float] = []
	for i in count:
		angles.append(base_angle + step * i)
	return angles

static func sweeping_arc(base_angle: float, count: int, arc_width: float) -> Array[float]:
	return aimed_volley(base_angle, count, arc_width)
