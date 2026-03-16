## Garou Monster Fist projectile — a dark, cracked energy fist.
extends Area2D

var _direction := Vector2.RIGHT
var _speed := 400.0
var _damage := 20.0
var _lifetime := 1.2
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
	_spin += delta * 15.0
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
	var alpha := 1.0 - (_elapsed / _lifetime) * 0.5
	# Dark monster energy glow
	draw_circle(Vector2.ZERO, 10.0, Color(0.15, 0.0, 0.3, alpha * 0.4))
	draw_circle(Vector2.ZERO, 7.0, Color(0.3, 0.0, 0.5, alpha * 0.8))
	draw_circle(Vector2.ZERO, 4.0, Color(0.6, 0.1, 0.8, alpha))
	draw_circle(Vector2.ZERO, 2.0, Color(0.9, 0.4, 1.0, alpha))
	# Energy cracks
	for i in 4:
		var a := _spin + i * TAU / 4.0
		var p1 := Vector2(cos(a), sin(a)) * 4.0
		var p2 := Vector2(cos(a + 0.5), sin(a + 0.5)) * 9.0
		draw_line(p1, p2, Color(0.7, 0.2, 1.0, alpha * 0.6), 1.5)
	# Trail
	draw_line(Vector2.ZERO, -_direction * 12.0, Color(0.4, 0.0, 0.6, alpha * 0.35), 3.0)
