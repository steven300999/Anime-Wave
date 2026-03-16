extends Node2D

signal wave_started(wave_number: int)
signal all_enemies_killed
signal enemy_killed
signal enemy_spawned

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")
const EXP_SCENE := preload("res://scenes/exp_orb.tscn")

@export var spawn_radius_min := 500.0
@export var spawn_radius_max := 700.0

var wave_number := 0
var enemies_alive := 0
var enemies_to_spawn := 0
var _spawn_timer := 0.0
var _spawn_interval := 0.5
var _wave_cooldown := 0.0
var _wave_cooldown_time := 3.0
var _between_waves := false
var _active := false

var _health_multiplier := 1.0
var _speed_bonus := 0.0

func _ready() -> void:
	pass

func start() -> void:
	_active = true
	_start_wave()

func _process(delta: float) -> void:
	if not _active:
		return
	if _between_waves:
		_wave_cooldown -= delta
		if _wave_cooldown <= 0.0:
			_between_waves = false
			_start_wave()
		return
	if enemies_to_spawn > 0:
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn_enemy()
			_spawn_timer = _spawn_interval
			enemies_to_spawn -= 1

func _start_wave() -> void:
	wave_number += 1
	# Scale difficulty each wave
	var base_count := 5 + (wave_number - 1) * 3
	enemies_to_spawn = base_count
	enemies_alive = 0
	_health_multiplier = 1.0 + (wave_number - 1) * 0.25
	_speed_bonus = max(0.0, (wave_number - 3) * 8.0)
	_spawn_interval = max(0.15, 0.5 - wave_number * 0.03)
	_spawn_timer = 0.0
	wave_started.emit(wave_number)

func _spawn_enemy() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	# Spawn at a random point around the player just outside the viewport
	var angle := randf() * TAU
	var dist := randf_range(spawn_radius_min, spawn_radius_max)
	var spawn_pos := player.global_position + Vector2(cos(angle), sin(angle)) * dist
	var enemy: Node2D = ENEMY_SCENE.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_pos
	if enemy.has_method("setup"):
		enemy.setup(_health_multiplier, _speed_bonus)
	enemy.connect("died", _on_enemy_died)
	enemies_alive += 1
	enemy_spawned.emit()

func _on_enemy_died(pos: Vector2, exp_val: int) -> void:
	_spawn_exp_orb(pos, exp_val)
	enemy_killed.emit()
	enemies_alive -= 1
	if enemies_alive <= 0 and enemies_to_spawn <= 0:
		_between_waves = true
		_wave_cooldown = _wave_cooldown_time
		all_enemies_killed.emit()

func _spawn_exp_orb(pos: Vector2, exp_val: int) -> void:
	var orb: Node2D = EXP_SCENE.instantiate()
	if "exp_value" in orb:
		orb.exp_value = exp_val
	orb.position = pos + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	get_tree().current_scene.call_deferred("add_child", orb)
