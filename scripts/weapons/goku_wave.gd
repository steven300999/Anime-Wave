## Goku Kamehameha wave — powerful blue ki energy projectile.
extends Area2D

var _direction := Vector2.RIGHT
var _speed := 360.0
var _damage := 35.0
var _lifetime := 2.0
var _elapsed := 0.0
var _spin := 0.0

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
	_spin += delta * 6.0
	if _elapsed >= _lifetime:
		queue_free()
		return
	global_position += _direction * _speed * delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(_damage)
		queue_free()

func _draw() -> void:
	var alpha := clampf(1.0 - (_elapsed / _lifetime) * 0.5, 0.0, 1.0)
	# Deep blue Kamehameha ki
	draw_circle(Vector2.ZERO, 14.0, Color(0.2, 0.4, 1.0, alpha * 0.3))
	draw_circle(Vector2.ZERO, 9.0, Color(0.3, 0.6, 1.0, alpha))
	draw_circle(Vector2.ZERO, 5.5, Color(0.7, 0.9, 1.0, alpha))
	draw_circle(Vector2.ZERO, 2.5, Color(1.0, 1.0, 1.0, alpha))
	# Ki rings
	for i in 4:
		var a := _spin + i * TAU / 4.0
		var p := Vector2(cos(a), sin(a)) * 10.0
		draw_line(Vector2.ZERO, p, Color(0.5, 0.8, 1.0, alpha * 0.5), 1.5)
	# Bright blue trail
	draw_line(Vector2.ZERO, -_direction * 18.0, Color(0.2, 0.5, 1.0, alpha * 0.4), 4.0)
