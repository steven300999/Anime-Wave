## Cursed Energy Blast projectile — dark purple bolt with JJK aesthetics.
extends Area2D

const TRAIL_MAX := 12
const TRAIL_COLOR := Color(0.55, 0.0, 0.85)

var _direction := Vector2.RIGHT
var _speed := 320.0
var _damage := 20.0
var _lifetime := 1.8
var _elapsed := 0.0
var _spin := 0.0
var _trail: Array[Vector2] = []

func setup(direction: Vector2, dmg: float, spd: float) -> void:
	_direction = direction.normalized()
	_damage = dmg
	_speed = spd
	rotation = _direction.angle()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	_spin += delta * 8.0
	if _elapsed >= _lifetime:
		queue_free()
		return
	_trail.append(global_position)
	if _trail.size() > TRAIL_MAX:
		_trail.pop_front()
	global_position += _direction * _speed * delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(_damage)
		queue_free()

func _draw() -> void:
	var alpha := 1.0 - (_elapsed / _lifetime) * 0.6
	# Colored trail — fading purple dots
	var n := _trail.size()
	for i in n:
		var local_pos := to_local(_trail[i])
		var t := float(i) / float(TRAIL_MAX)
		draw_circle(local_pos, lerp(1.0, 5.0, t), Color(TRAIL_COLOR.r, TRAIL_COLOR.g, TRAIL_COLOR.b, t * 0.65))
	# Outer cursed aura
	draw_circle(Vector2.ZERO, 10.0, Color(0.3, 0.0, 0.5, alpha * 0.4))
	# Main bolt body
	draw_circle(Vector2.ZERO, 6.0, Color(0.55, 0.0, 0.8, alpha))
	draw_circle(Vector2.ZERO, 3.5, Color(0.75, 0.2, 1.0, alpha))
	draw_circle(Vector2.ZERO, 1.5, Color(1.0, 0.8, 1.0, alpha))
	# Cursed energy wisps
	for i in 4:
		var a := _spin + i * TAU / 4.0
		var p := Vector2(cos(a), sin(a)) * 7.0
		draw_line(Vector2.ZERO, p, Color(0.4, 0.0, 0.6, alpha * 0.5), 1.5)
	# Trail
	draw_line(Vector2.ZERO, -_direction * 18.0, Color(0.4, 0.0, 0.6, alpha * 0.45), 3.0)
