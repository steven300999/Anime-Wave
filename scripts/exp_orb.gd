extends Area2D

@export var exp_value := 20
var _player: Node2D = null
var _attracted := false
var _attract_radius := 80.0
var _move_speed := 160.0
var _bob_timer := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_player = get_tree().get_first_node_in_group("player") as Node2D
	queue_redraw()

func _process(delta: float) -> void:
	_bob_timer += delta
	queue_redraw()
	if not _attracted:
		if _player != null and is_instance_valid(_player):
			if global_position.distance_to(_player.global_position) <= _attract_radius:
				_attracted = true
	if _attracted and _player != null and is_instance_valid(_player):
		var dir := (_player.global_position - global_position).normalized()
		global_position += dir * _move_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.gain_exp(exp_value)
		queue_free()

func _draw() -> void:
	var pulse := (sin(_bob_timer * 4.0) + 1.0) * 0.5
	var inner_r := 5.0 + pulse * 2.0
	var outer_r := 9.0 + pulse * 3.0
	# Outer glow
	draw_circle(Vector2.ZERO, outer_r, Color(0.2, 0.8, 1.0, 0.3))
	# Inner orb
	draw_circle(Vector2.ZERO, inner_r, Color(0.4, 0.9, 1.0))
	# Bright core
	draw_circle(Vector2.ZERO, inner_r * 0.5, Color(1.0, 1.0, 1.0, 0.9))
