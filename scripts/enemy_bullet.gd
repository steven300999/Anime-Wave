extends Area2D

var _direction := Vector2.RIGHT
var _speed := 220.0
var _damage := 8.0
var _lifetime := 4.0
var _elapsed := 0.0
var _owner_id := -1
var _target_group := "player"

func setup(direction: Vector2, speed: float, damage: float, owner_id: int = -1, target_group: String = "player") -> void:
	_direction = direction.normalized()
	_speed = speed
	_damage = damage
	_owner_id = owner_id
	_target_group = target_group
	rotation = _direction.angle()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("enemy_bullets")
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _lifetime:
		queue_free()
		return
	global_position += _direction * _speed * delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.get_instance_id() == _owner_id:
		return
	if not body.is_in_group(_target_group):
		return
	if body.has_method("take_damage"):
		body.take_damage(_damage)
	queue_free()

func _draw() -> void:
	var alpha := 1.0 - (_elapsed / _lifetime)
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.25, 0.35, alpha * 0.8))
	draw_circle(Vector2.ZERO, 2.2, Color(1.0, 0.8, 0.85, alpha))
	draw_line(Vector2.ZERO, -_direction * 8.0, Color(1.0, 0.4, 0.4, alpha * 0.4), 2.0)
