extends CharacterBody2D

signal died(pos: Vector2, exp_value: int)

@export var base_speed := 80.0
@export var base_health := 30.0
@export var base_damage := 10.0
@export var base_exp := 20

var current_health: float
var speed: float
var damage: float
var exp_drop: int

var _player: Node2D = null
var _flash_timer := 0.0
var _damage_cooldown := 0.0
const DAMAGE_INTERVAL := 0.6

func _ready() -> void:
	add_to_group("enemies")
	current_health = base_health
	speed = base_speed
	damage = base_damage
	exp_drop = base_exp
	queue_redraw()

func setup(health_mult: float, speed_bonus: float) -> void:
	base_health = base_health * health_mult
	current_health = base_health
	speed = base_speed + speed_bonus
	exp_drop = int(base_exp * health_mult)

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()
	# Contact damage — tick down cooldown and check proximity
	if _damage_cooldown > 0.0:
		_damage_cooldown -= delta
	else:
		if global_position.distance_to(_player.global_position) < 28.0:
			if _player.has_method("take_damage"):
				_player.take_damage(damage)
			_damage_cooldown = DAMAGE_INTERVAL

func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		modulate = Color(2.0, 0.5, 0.5) if int(_flash_timer * 20) % 2 == 0 else Color.WHITE
		if _flash_timer <= 0.0:
			modulate = Color.WHITE

func take_damage(amount: float) -> void:
	current_health -= amount
	_flash_timer = 0.15
	if current_health <= 0.0:
		_on_death()

func _on_death() -> void:
	died.emit(global_position, exp_drop)
	queue_free()

func _draw() -> void:
	# Curse/zombie enemy placeholder — dark menacing figure
	var body_color := Color(0.25, 0.08, 0.35)
	var glow_color := Color(0.6, 0.0, 0.8, 0.4)
	# Glow aura
	draw_circle(Vector2.ZERO, 18, glow_color)
	# Body
	draw_rect(Rect2(-8, -4, 16, 18), body_color)
	# Head
	draw_circle(Vector2(0, -12), 11, body_color)
	# Glowing eyes
	draw_circle(Vector2(-4, -13), 3, Color(0.9, 0.0, 0.0))
	draw_circle(Vector2(4, -13), 3, Color(0.9, 0.0, 0.0))
	draw_circle(Vector2(-4, -13), 1.5, Color(1.0, 0.5, 0.0))
	draw_circle(Vector2(4, -13), 1.5, Color(1.0, 0.5, 0.0))
	# Claws / arms
	draw_line(Vector2(-8, 2), Vector2(-18, 8), body_color, 4)
	draw_line(Vector2(-18, 8), Vector2(-22, 4), Color(0.4, 0.0, 0.5), 3)
	draw_line(Vector2(-18, 8), Vector2(-21, 12), Color(0.4, 0.0, 0.5), 3)
	draw_line(Vector2(8, 2), Vector2(18, 8), body_color, 4)
	draw_line(Vector2(18, 8), Vector2(22, 4), Color(0.4, 0.0, 0.5), 3)
	draw_line(Vector2(18, 8), Vector2(21, 12), Color(0.4, 0.0, 0.5), 3)
	# Legs
	draw_rect(Rect2(-8, 14, 6, 12), body_color)
	draw_rect(Rect2(2, 14, 6, 12), body_color)
