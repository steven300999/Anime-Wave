extends CharacterBody2D

signal health_changed(current: float, maximum: float)
signal exp_changed(current: int, required: int)
signal leveled_up(new_level: int)
signal died

const SPEED := 200.0
const INVINCIBILITY_DURATION := 0.5

var max_health := 100.0
var current_health := 100.0
var level := 1
var current_exp := 0
var exp_required := 100
var damage_multiplier := 1.0
var speed_multiplier := 1.0

var _invincible := false
var _inv_timer := 0.0
var _facing_right := true

func _ready() -> void:
	add_to_group("player")
	current_health = max_health
	queue_redraw()

func _process(delta: float) -> void:
	if _invincible:
		_inv_timer -= delta
		if _inv_timer <= 0.0:
			_invincible = false
			modulate = Color.WHITE
		else:
			modulate = Color(1, 1, 1, 0.5) if int(_inv_timer * 10) % 2 == 0 else Color.WHITE

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = dir * SPEED * speed_multiplier
	move_and_slide()
	if dir.x != 0:
		_facing_right = dir.x > 0
		scale.x = 1.0 if _facing_right else -1.0

func take_damage(amount: float) -> void:
	if _invincible:
		return
	current_health = clamp(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)
	_invincible = true
	_inv_timer = INVINCIBILITY_DURATION
	if current_health <= 0.0:
		_on_death()

func gain_exp(amount: int) -> void:
	current_exp += amount
	while current_exp >= exp_required:
		current_exp -= exp_required
		_do_level_up()
	exp_changed.emit(current_exp, exp_required)

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func get_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	var nearest: Node2D = null
	var min_dist := INF
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var d := global_position.distance_to((e as Node2D).global_position)
		if d < min_dist:
			min_dist = d
			nearest = e as Node2D
	return nearest

func _do_level_up() -> void:
	level += 1
	exp_required = int(exp_required * 1.5)
	max_health += 10.0
	current_health = min(current_health + 20.0, max_health)
	health_changed.emit(current_health, max_health)
	leveled_up.emit(level)

func _on_death() -> void:
	died.emit()
	set_process(false)
	set_physics_process(false)
	hide()

func _draw() -> void:
	# Anime-style character placeholder
	# Legs
	draw_rect(Rect2(-9, 14, 7, 14), Color(0.1, 0.3, 0.7))
	draw_rect(Rect2(2, 14, 7, 14), Color(0.1, 0.3, 0.7))
	# Body / uniform
	draw_rect(Rect2(-10, -4, 20, 20), Color(0.15, 0.45, 0.85))
	# Belt
	draw_rect(Rect2(-10, 10, 20, 4), Color(0.05, 0.15, 0.4))
	# Neck
	draw_rect(Rect2(-3, -8, 6, 5), Color(0.95, 0.78, 0.65))
	# Head
	draw_circle(Vector2(0, -16), 12, Color(0.95, 0.78, 0.65))
	# Hair (spiky anime style)
	var hair_color := Color(0.12, 0.08, 0.05)
	draw_circle(Vector2(0, -24), 9, hair_color)
	# Hair spikes
	draw_line(Vector2(-10, -22), Vector2(-15, -30), hair_color, 4.0)
	draw_line(Vector2(-5, -26), Vector2(-7, -34), hair_color, 3.5)
	draw_line(Vector2(0, -27), Vector2(0, -35), hair_color, 3.5)
	draw_line(Vector2(5, -26), Vector2(7, -34), hair_color, 3.5)
	draw_line(Vector2(10, -22), Vector2(15, -30), hair_color, 4.0)
	# Eyes
	draw_circle(Vector2(-4, -16), 2.5, Color(0.1, 0.5, 1.0))
	draw_circle(Vector2(4, -16), 2.5, Color(0.1, 0.5, 1.0))
	draw_circle(Vector2(-4, -16), 1, Color(0.0, 0.0, 0.0))
	draw_circle(Vector2(4, -16), 1, Color(0.0, 0.0, 0.0))
	# Headband (ninja style)
	draw_rect(Rect2(-12, -21, 24, 5), Color(0.3, 0.3, 0.3), false, 1.5)
	draw_rect(Rect2(-12, -21, 24, 5), Color(0.2, 0.2, 0.2, 0.5))
	# Arms
	draw_rect(Rect2(-16, -4, 6, 16), Color(0.15, 0.45, 0.85))
	draw_rect(Rect2(10, -4, 6, 16), Color(0.15, 0.45, 0.85))
	# Hands
	draw_circle(Vector2(-13, 14), 4, Color(0.95, 0.78, 0.65))
	draw_circle(Vector2(13, 14), 4, Color(0.95, 0.78, 0.65))
