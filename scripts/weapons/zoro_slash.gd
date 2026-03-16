## Zoro Three Sword Style slash wave — dark green blade that travels outward,
## damaging enemies in its path.
extends Area2D

var _direction := Vector2.RIGHT
var _speed := 280.0
var _damage := 30.0
var _lifetime := 1.0
var _elapsed := 0.0
var _hit_enemies: Array = []

func setup(direction: Vector2, dmg: float) -> void:
	_direction = direction.normalized()
	_damage = dmg
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
	if body.is_in_group("enemies") and body not in _hit_enemies:
		_hit_enemies.append(body)
		if body.has_method("take_damage"):
			body.take_damage(_damage)

func _draw() -> void:
	var alpha := clampf(1.0 - _elapsed / _lifetime, 0.0, 1.0)
	# Dark green sword slash arc
	var points := PackedVector2Array()
	for i in 16:
		var t := float(i) / 15.0
		var angle: float = lerp(-PI * 0.3, PI * 0.3, t)
		var r := 20.0 + sin(t * PI) * 10.0
		points.append(Vector2(cos(angle), sin(angle)) * r)
	# Outer dark slash
	for i in points.size() - 1:
		draw_line(points[i], points[i + 1], Color(0.05, 0.45, 0.1, alpha * 0.9), 5.0)
	# Inner bright edge
	for i in points.size() - 1:
		draw_line(points[i], points[i + 1], Color(0.3, 0.9, 0.2, alpha * 0.7), 2.0)
	# Core glow
	draw_circle(Vector2.ZERO, 5.0, Color(0.0, 0.8, 0.1, alpha * 0.6))
