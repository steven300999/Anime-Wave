extends Node2D

@onready var player = $Player
@onready var wave_manager = $WaveManager
@onready var hud = $UI
@onready var level_up_ui = $LevelUpUI
@onready var camera: Camera2D = $Camera2D

var kill_count := 0
## Maps path_id -> current level (0 / absent = unowned, 1-5 = upgrades,
## 6 = Limit Break, 7 = Evolution).
var path_levels: Dictionary = {}
## True once the player has unlocked any Evolution (level 7) upgrade.
var has_evolution: bool = false

var _weapons_by_id: Dictionary = {}

const _WEAPON_SCRIPTS := {
	"basic_shot": "res://scripts/weapons/basic_shot.gd",
	"rasengan": "res://scripts/weapons/rasengan.gd",
	"water_breathing": "res://scripts/weapons/water_breathing.gd",
	"cursed_energy": "res://scripts/weapons/cursed_energy.gd",
}

## Maps path_id to the weapon it controls.
const _PATH_WEAPON := {
	"naruto": "rasengan",
	"tanjiro": "water_breathing",
	"itadori": "cursed_energy",
}

## Standard per-level damage multiplier applied at most path upgrade tiers.
const _DAMAGE_BOOST := 1.3

func _ready() -> void:
	# Connect player signals
	player.health_changed.connect(hud.update_health)
	player.exp_changed.connect(hud.update_exp)
	player.leveled_up.connect(_on_player_leveled_up)
	player.died.connect(_on_player_died)

	# Initialize HUD
	hud.update_health(player.current_health, player.max_health)
	hud.update_exp(0, player.exp_required)
	hud.update_level(1)

	# Connect wave manager signals
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.all_enemies_killed.connect(_on_all_enemies_killed)
	wave_manager.enemy_killed.connect(increment_kill)

	# Connect level-up UI
	level_up_ui.ability_chosen.connect(_on_ability_chosen)

	# Register camera for background script
	camera.add_to_group("main_camera")

	# Give player starting weapon
	_give_weapon("basic_shot")

	# Start waves
	wave_manager.start()

	# Start background scroll
	_setup_background()

func _process(_delta: float) -> void:
	# Camera follows player
	if is_instance_valid(player):
		camera.global_position = player.global_position

func _setup_background() -> void:
	pass  # Background script on BackgroundTiles handles itself

func _on_player_leveled_up(level: int) -> void:
	hud.update_level(level)
	level_up_ui.show_choices(level, path_levels, has_evolution)

func _on_player_died() -> void:
	# Wait briefly then show game over (player is hidden but not freed)
	await get_tree().create_timer(0.8).timeout
	var game_over: Node = load("res://scenes/game_over.tscn").instantiate()
	game_over.setup(kill_count, hud.get_elapsed(), player.level)
	get_tree().root.add_child(game_over)
	queue_free()

func _on_wave_started(wave: int) -> void:
	hud.update_wave(wave)

func _on_all_enemies_killed() -> void:
	pass  # Next wave starts automatically after cooldown

func _on_ability_chosen(path_id: String) -> void:
	var current_level: int = path_levels.get(path_id, 0)
	var new_level: int = current_level + 1
	path_levels[path_id] = new_level
	if new_level == 7:
		has_evolution = true
	_apply_path_upgrade(path_id, new_level)

## Apply gameplay stat changes for a path reaching the given level.
func _apply_path_upgrade(path_id: String, level: int) -> void:
	var weapon_id: String = _PATH_WEAPON.get(path_id, "")
	if weapon_id.is_empty():
		return

	# Level 1: spawn the weapon for the first time
	if level == 1:
		_give_weapon(weapon_id)
		return

	var weapon_node = _weapons_by_id.get(weapon_id, null)
	if not is_instance_valid(weapon_node):
		return

	match path_id:
		"naruto":
			match level:
				2, 4, 5:
					weapon_node.damage *= _DAMAGE_BOOST
				3:  # Twin Rasengan — bigger jump
					weapon_node.damage *= 1.5
				6:  # Limit Break: Ultra Rasengan
					weapon_node.damage *= 3.0
				7:  # Evolution: Nine-Tails Mode
					weapon_node.damage *= 2.0
					player.speed_multiplier += 1.0
		"tanjiro":
			match level:
				2:
					weapon_node.damage *= _DAMAGE_BOOST
				3:  # Flowing Dance — faster slashes
					weapon_node.damage *= _DAMAGE_BOOST
					weapon_node.cooldown = max(weapon_node.cooldown * 0.65, 0.4)
				4, 5:
					weapon_node.damage *= _DAMAGE_BOOST
				6:  # Limit Break: Hinokami Kagura
					weapon_node.damage *= 3.0
				7:  # Evolution: Demon Slayer Mark
					weapon_node.damage *= 2.0
					weapon_node.cooldown = max(weapon_node.cooldown * 0.5, 0.3)
		"itadori":
			match level:
				2, 3, 4:
					weapon_node.damage *= _DAMAGE_BOOST
				5:  # 1000 Strikes — faster fire rate
					weapon_node.damage *= _DAMAGE_BOOST
					weapon_node.cooldown = max(weapon_node.cooldown * 0.6, 0.4)
				6:  # Limit Break: Black Flash
					weapon_node.damage *= 3.0
				7:  # Evolution: Sukuna's Domain
					weapon_node.damage *= 2.0
					weapon_node.cooldown = max(weapon_node.cooldown * 0.5, 0.3)

func _give_weapon(weapon_id: String) -> void:
	if _weapons_by_id.has(weapon_id):
		return  # Already equipped
	if not _WEAPON_SCRIPTS.has(weapon_id):
		return
	var weapon_node := Node2D.new()
	weapon_node.set_script(load(_WEAPON_SCRIPTS[weapon_id]))
	player.add_child(weapon_node)
	_weapons_by_id[weapon_id] = weapon_node

func increment_kill() -> void:
	kill_count += 1
	hud.update_kills(kill_count)
