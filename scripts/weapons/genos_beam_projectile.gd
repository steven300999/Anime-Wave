## Genos Incineration Cannon projectile — a blazing fire bolt.
extends Area2D

var _direction := Vector2.RIGHT
var _speed := 350.0
var _damage := 30.0
var _lifetime := 1.5
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
	_spin += delta * 10.0
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
	# Fire outer glow
	draw_circle(Vector2.ZERO, 9.0, Color(1.0, 0.4, 0.0, alpha * 0.45))
	# Fire core
	draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.6, 0.1, alpha))
	draw_circle(Vector2.ZERO, 3.5, Color(1.0, 0.85, 0.3, alpha))
	draw_circle(Vector2.ZERO, 1.5, Color(1.0, 1.0, 0.8, alpha))
	# Fire wisps
	for i in 5:
		var a := _spin + i * TAU / 5.0
		var p := Vector2(cos(a), sin(a)) * 8.0
		draw_line(Vector2.ZERO, p, Color(1.0, 0.35, 0.0, alpha * 0.4), 1.5)
	# Trail
	draw_line(Vector2.ZERO, -_direction * 16.0, Color(1.0, 0.5, 0.0, alpha * 0.4), 3.5)
