extends CharacterBody2D

signal eliminated(rival: Node)

const BULLET_SCENE := preload("res://scenes/enemy_bullet.tscn")

var max_health := 110.0
var current_health := 110.0
var speed := 170.0
var _fire_cooldown := 1.0
var _move_timer := 0.0
var _fire_timer := 0.0
var _move_dir := Vector2.RIGHT
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	add_to_group("rivals")
	add_to_group("enemies")
	add_to_group("combatants")
	_move_timer = _rng.randf_range(0.3, 1.2)
	_fire_timer = _rng.randf_range(0.3, 1.0)
	queue_redraw()

func _physics_process(delta: float) -> void:
	_move_timer -= delta
	if _move_timer <= 0.0:
		_move_timer = _rng.randf_range(0.8, 1.8)
		_move_dir = Vector2.RIGHT.rotated(_rng.randf_range(0.0, TAU))
	velocity = _move_dir * speed
	move_and_slide()

func _process(delta: float) -> void:
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire_timer = _fire_cooldown + _rng.randf_range(0.0, 0.5)
		_fire()

func _fire() -> void:
	var target := _get_target()
	if target == null:
		return
	var dir := global_position.direction_to(target.global_position)
	var bullet: Node2D = BULLET_SCENE.instantiate()
	bullet.global_position = global_position
	bullet.setup(dir, 230.0, 10.0, get_instance_id(), "combatants")
	get_tree().current_scene.add_child(bullet)

func _get_target() -> Node2D:
	var nearest: Node2D = null
	var best := INF
	for node in get_tree().get_nodes_in_group("combatants"):
		if node == self or not is_instance_valid(node):
			continue
		var n := node as Node2D
		var d := global_position.distance_to(n.global_position)
		if d < best:
			best = d
			nearest = n
	return nearest

func take_damage(amount: float) -> void:
	current_health = max(0.0, current_health - amount)
	if current_health <= 0.0:
		eliminated.emit(self)
		queue_free()

func _draw() -> void:
	draw_circle(Vector2.ZERO, 14, Color(0.6, 0.18, 0.85))
	draw_circle(Vector2(0, -4), 10, Color(0.95, 0.8, 0.7))
	draw_rect(Rect2(-7, 7, 14, 14), Color(0.3, 0.05, 0.4))
	draw_circle(Vector2(-3, -4), 1.8, Color.BLACK)
	draw_circle(Vector2(3, -4), 1.8, Color.BLACK)
