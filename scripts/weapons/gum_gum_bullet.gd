## Gum Gum Bullet — Luffy's stretched rubber-fist projectile.
extends Area2D

var _direction := Vector2.RIGHT
var _speed := 350.0
var _damage := 18.0
var _lifetime := 1.4
var _elapsed := 0.0

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
	# Rubber-fist knuckle
	draw_circle(Vector2.ZERO, 11.0, Color(0.92, 0.72, 0.55, alpha))
	for i in 4:
		var x := -7.5 + i * 5.0
		draw_circle(Vector2(x, -3.0), 3.0, Color(0.75, 0.55, 0.40, alpha))
	# Motion trail (backward in local space)
	draw_line(Vector2.ZERO, Vector2(-22.0, 0.0), Color(0.92, 0.72, 0.55, alpha * 0.25), 5.0)
