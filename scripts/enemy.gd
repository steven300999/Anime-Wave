extends CharacterBody2D

signal died(pos: Vector2, exp_value: int)

const BULLET_SCENE := preload("res://scenes/enemy_bullet.tscn")

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
var _attack_timer := 0.0
var _telegraph_timer := 0.0
var _spiral_seed := 0.0
var _archetype := "striker"
var _queued_pattern := ""
const DAMAGE_INTERVAL := 0.6

func _ready() -> void:
	add_to_group("enemies")
	current_health = base_health
	speed = base_speed
	damage = base_damage
	exp_drop = base_exp
	_attack_timer = randf_range(GameBalance.ENEMY["attack_min_cd"], GameBalance.ENEMY["attack_max_cd"])
	_spiral_seed = randf() * TAU
	queue_redraw()

func setup(health_mult: float, speed_bonus: float, archetype: String = "striker", is_elite: bool = false) -> void:
	base_health = base_health * health_mult
	current_health = base_health
	speed = base_speed + speed_bonus
	damage = base_damage + (health_mult - 1.0) * 2.0
	exp_drop = int(base_exp * health_mult)
	_archetype = archetype
	if is_elite:
		current_health *= 1.8
		damage *= 1.5
		scale = Vector2(1.25, 1.25)
		exp_drop = int(exp_drop * 1.6)

func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

	if _damage_cooldown > 0.0:
		_damage_cooldown -= delta
	elif global_position.distance_to(_player.global_position) < 28.0:
		if _player.has_method("take_damage"):
			_player.take_damage(damage)
		_damage_cooldown = DAMAGE_INTERVAL

func _process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta

	if _telegraph_timer > 0.0:
		_telegraph_timer -= delta
		modulate = Color(2.0, 0.5, 0.5) if int(_telegraph_timer * 24) % 2 == 0 else Color.WHITE
		if _telegraph_timer <= 0.0 and not _queued_pattern.is_empty():
			_fire_pattern(_queued_pattern)
			_queue_next_attack()
	elif _flash_timer <= 0.0:
		modulate = Color.WHITE

	_attack_timer -= delta
	if _attack_timer <= 0.0 and _telegraph_timer <= 0.0 and _player != null:
		_queued_pattern = _pick_pattern()
		_telegraph_timer = GameBalance.ENEMY["telegraph_time"]

func _pick_pattern() -> String:
	match _archetype:
		"spinner":
			return "radial"
		"sniper":
			return "sweep"
		_:
			return "aimed"

func _queue_next_attack() -> void:
	_queued_pattern = ""
	_attack_timer = randf_range(GameBalance.ENEMY["attack_min_cd"], GameBalance.ENEMY["attack_max_cd"])

func _fire_pattern(pattern: String) -> void:
	if _player == null:
		return
	var base_angle := global_position.direction_to(_player.global_position).angle()
	match pattern:
		"radial":
			var count := 12
			var gap_index := int(wrapf(base_angle / TAU * count, 0.0, float(count)))
			for angle in BulletPatterns.radial(count, gap_index):
				_spawn_bullet(Vector2(cos(angle), sin(angle)))
		"sweep":
			for angle in BulletPatterns.sweeping_arc(base_angle, 6, PI * 0.9):
				_spawn_bullet(Vector2(cos(angle), sin(angle)))
			var snapshot := _player.global_position
			await get_tree().create_timer(0.45).timeout
			if is_instance_valid(self):
				var delayed_base := global_position.direction_to(snapshot).angle()
				for angle in BulletPatterns.aimed_volley(delayed_base, 5, PI * 0.6):
					_spawn_bullet(Vector2(cos(angle), sin(angle)))
		_:
			for angle in BulletPatterns.aimed_volley(base_angle, 4, PI * 0.45):
				_spawn_bullet(Vector2(cos(angle), sin(angle)))
			_spiral_seed += PI * 0.15
			for angle in BulletPatterns.spiral(_spiral_seed, 2, PI):
				_spawn_bullet(Vector2(cos(angle), sin(angle)))

func _spawn_bullet(dir: Vector2) -> void:
	var bullet: Node2D = BULLET_SCENE.instantiate()
	bullet.global_position = global_position
	bullet.setup(dir, GameBalance.ENEMY["bullet_speed"], damage * 0.8)
	get_tree().current_scene.add_child(bullet)

func take_damage(amount: float) -> void:
	current_health -= amount
	_flash_timer = 0.12
	if current_health <= 0.0:
		_on_death()

func _on_death() -> void:
	died.emit(global_position, exp_drop)
	queue_free()

func _draw() -> void:
	var body_color := Color(0.25, 0.08, 0.35)
	var glow_color := Color(0.6, 0.0, 0.8, 0.4)
	draw_circle(Vector2.ZERO, 18, glow_color)
	draw_rect(Rect2(-8, -4, 16, 18), body_color)
	draw_circle(Vector2(0, -12), 11, body_color)
	draw_circle(Vector2(-4, -13), 3, Color(0.9, 0.0, 0.0))
	draw_circle(Vector2(4, -13), 3, Color(0.9, 0.0, 0.0))
	draw_circle(Vector2(-4, -13), 1.5, Color(1.0, 0.5, 0.0))
	draw_circle(Vector2(4, -13), 1.5, Color(1.0, 0.5, 0.0))
	draw_line(Vector2(-8, 2), Vector2(-18, 8), body_color, 4)
	draw_line(Vector2(-18, 8), Vector2(-22, 4), Color(0.4, 0.0, 0.5), 3)
	draw_line(Vector2(-18, 8), Vector2(-21, 12), Color(0.4, 0.0, 0.5), 3)
	draw_line(Vector2(8, 2), Vector2(18, 8), body_color, 4)
	draw_line(Vector2(18, 8), Vector2(22, 4), Color(0.4, 0.0, 0.5), 3)
	draw_line(Vector2(18, 8), Vector2(21, 12), Color(0.4, 0.0, 0.5), 3)
	draw_rect(Rect2(-8, 14, 6, 12), body_color)
	draw_rect(Rect2(2, 14, 6, 12), body_color)
