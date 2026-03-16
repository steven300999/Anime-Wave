## Dragon Ball energy projectile — shared projectile used by all Dragon Ball
## path weapons. Rendered via Canvas2D drawing; uses manual distance checking
## for hit detection so no physics scene file is required.
extends Node2D

var _direction := Vector2.RIGHT
var _speed := 350.0
var _damage := 18.0
var _lifetime := 1.8
var _elapsed := 0.0
var _color_core := Color(1.0, 0.7, 0.1)
var _color_glow := Color(1.0, 0.95, 0.4)
var _radius := 8.0
var _piercing := false
var _hit_enemies: Array = []
var _spin := 0.0

func setup(dir: Vector2, dmg: float, spd: float, core: Color, glow: Color,
		radius: float = 8.0, pierce: bool = false) -> void:
	_direction = dir.normalized()
	_damage = dmg
	_speed = spd
	_color_core = core
	_color_glow = glow
	_radius = radius
	_piercing = pierce

func _process(delta: float) -> void:
	_elapsed += delta
	_spin += delta * 10.0
	if _elapsed >= _lifetime:
		queue_free()
		return
	global_position += _direction * _speed * delta
	_check_hits()
	queue_redraw()

func _check_hits() -> void:
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e):
			continue
		if e in _hit_enemies:
			continue
		var enemy := e as Node2D
		if global_position.distance_to(enemy.global_position) < _radius + 14.0:
			_hit_enemies.append(enemy)
			if enemy.has_method("take_damage"):
				enemy.take_damage(_damage)
			if not _piercing:
				queue_free()
				return

func _draw() -> void:
	var alpha := 1.0 - (_elapsed / _lifetime) * 0.5
	# Outer glow halo
	draw_circle(Vector2.ZERO, _radius * 1.8,
		Color(_color_glow.r, _color_glow.g, _color_glow.b, alpha * 0.25))
	# Main energy core
	draw_circle(Vector2.ZERO, _radius,
		Color(_color_core.r, _color_core.g, _color_core.b, alpha))
	# Bright center flash
	draw_circle(Vector2.ZERO, _radius * 0.45, Color(1.0, 1.0, 1.0, alpha * 0.9))
	# Spinning energy wisps
	for i in 4:
		var a := _spin + i * TAU / 4.0
		var p := Vector2(cos(a), sin(a)) * _radius
		draw_line(Vector2.ZERO, p,
			Color(_color_glow.r, _color_glow.g, _color_glow.b, alpha * 0.4), 1.5)
	# Motion trail
	draw_line(Vector2.ZERO, -_direction * _radius * 2.2,
		Color(_color_core.r, _color_core.g, _color_core.b, alpha * 0.35), 3.0)
