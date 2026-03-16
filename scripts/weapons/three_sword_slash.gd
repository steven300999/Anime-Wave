## Three Sword Slash — Zoro's sword-slash wave that can pierce multiple enemies.
extends Area2D

var _direction := Vector2.RIGHT
var _speed := 280.0
var _damage := 30.0
var _lifetime := 1.0
var _elapsed := 0.0
var _hit_enemies: Array = []
var _black_blade := false

func setup(direction: Vector2, dmg: float, black: bool = false) -> void:
	_direction = direction.normalized()
	_damage = dmg
	_black_blade = black
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
	var alpha := 1.0 - (_elapsed / _lifetime)
	var col1 := Color(0.15, 0.15, 0.1, alpha * 0.9) if _black_blade else Color(0.85, 0.85, 0.3, alpha * 0.9)
	var col2 := Color(0.4, 0.0, 0.6, alpha * 0.6) if _black_blade else Color(1.0, 1.0, 0.6, alpha * 0.6)
	# Sword slash arc
	var points := PackedVector2Array()
	for i in 20:
		var t := float(i) / 19.0
		var angle: float = lerp(-PI * 0.4, PI * 0.4, t)
		var r := 24.0 + sin(t * PI) * 10.0
		points.append(Vector2(cos(angle), sin(angle)) * r)
	for i in points.size() - 1:
		draw_line(points[i], points[i + 1], col1, 5.0)
	for i in points.size() - 1:
		draw_line(points[i], points[i + 1], col2, 2.0)
