## Water Breathing slash wave — travels outward and damages enemies in its path.
extends Area2D

const TRAIL_MAX := 10
const TRAIL_COLOR := Color(0.2, 0.65, 1.0)

var _direction := Vector2.RIGHT
var _speed := 260.0
var _damage := 35.0
var _lifetime := 1.2
var _elapsed := 0.0
var _hit_enemies: Array = []
var _trail: Array[Vector2] = []

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
	_trail.append(global_position)
	if _trail.size() > TRAIL_MAX:
		_trail.pop_front()
	global_position += _direction * _speed * delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body not in _hit_enemies:
		_hit_enemies.append(body)
		if body.has_method("take_damage"):
			body.take_damage(_damage)

func _draw() -> void:
	var alpha := 1.0 - (_elapsed / _lifetime)
	# Colored trail — fading cyan smear behind the slash
	var n := _trail.size()
	for i in n:
		var local_pos := to_local(_trail[i])
		var t := float(i) / float(TRAIL_MAX)
		draw_circle(local_pos, lerp(2.0, 8.0, t), Color(TRAIL_COLOR.r, TRAIL_COLOR.g, TRAIL_COLOR.b, t * 0.5))
	# Water-blue crescent slash shape
	var points := PackedVector2Array()
	for i in 16:
		var t := float(i) / 15.0
		var angle: float = lerp(-PI * 0.35, PI * 0.35, t)
		var r := 22.0 + sin(t * PI) * 8.0
		points.append(Vector2(cos(angle), sin(angle)) * r)
	# Draw as a thick arc
	for i in points.size() - 1:
		draw_line(points[i], points[i + 1], Color(0.3, 0.7, 1.0, alpha * 0.9), 5.0)
	# Inner glow
	for i in points.size() - 1:
		draw_line(points[i], points[i + 1], Color(0.8, 0.95, 1.0, alpha * 0.6), 2.0)
	# Foam sparkles
	draw_circle(Vector2(0, 0), 6.0, Color(1.0, 1.0, 1.0, alpha * 0.5))
