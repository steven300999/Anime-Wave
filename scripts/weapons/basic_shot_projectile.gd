## Basic projectile fired by the Basic Shot weapon.
extends Area2D

const TRAIL_MAX := 12
const TRAIL_COLOR := Color(1.0, 0.85, 0.1)

var _direction := Vector2.RIGHT
var _speed := 380.0
var _damage := 12.0
var _lifetime := 2.0
var _elapsed := 0.0
var _angle := 0.0
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
	_angle += delta * 12.0
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
	# Colored trail — fading yellow dots
	var n := _trail.size()
	for i in n:
		var local_pos := to_local(_trail[i])
		var t := float(i) / float(TRAIL_MAX)
		draw_circle(local_pos, lerp(1.0, 4.5, t), Color(TRAIL_COLOR.r, TRAIL_COLOR.g, TRAIL_COLOR.b, t * 0.7))
	# Glowing yellow energy ball
	draw_circle(Vector2.ZERO, 7.0, Color(1.0, 0.9, 0.2, 0.5))
	draw_circle(Vector2.ZERO, 4.5, Color(1.0, 0.95, 0.4))
	draw_circle(Vector2.ZERO, 2.0, Color(1.0, 1.0, 0.9))
	# Trailing lines
	draw_line(Vector2.ZERO, -_direction * 14.0, Color(1.0, 0.8, 0.1, 0.5), 2.5)
