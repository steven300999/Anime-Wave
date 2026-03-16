extends Node2D

@onready var player = $Player
@onready var wave_manager = $WaveManager
@onready var hud = $UI
@onready var level_up_ui = $LevelUpUI
@onready var camera: Camera2D = $Camera2D

var kill_count := 0
var _owned_abilities: Array[String] = []
var _weapons_by_id: Dictionary = {}

const _WEAPON_SCRIPTS := {
	"basic_shot": "res://scripts/weapons/basic_shot.gd",
	"rasengan": "res://scripts/weapons/rasengan.gd",
	"water_breathing": "res://scripts/weapons/water_breathing.gd",
	"cursed_energy": "res://scripts/weapons/cursed_energy.gd",
}

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
	level_up_ui.show_choices(level, _owned_abilities)

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

func _on_ability_chosen(ability_id: String) -> void:
	if ability_id == "heal":
		player.heal(30.0)
	elif ability_id == "speed_up":
		player.speed_multiplier += 0.2
	elif ability_id == "damage_up":
		player.damage_multiplier += 0.25
		_apply_damage_buff(1.25)
	elif ability_id == "limit_break":
		_activate_limit_break()
	elif ability_id == "evolution":
		_activate_evolution()
	else:
		_give_weapon(ability_id)
	_owned_abilities.append(ability_id)

func _give_weapon(weapon_id: String) -> void:
	if _weapons_by_id.has(weapon_id):
		return  # Already equipped
	if not _WEAPON_SCRIPTS.has(weapon_id):
		return
	var weapon_node := Node2D.new()
	weapon_node.set_script(load(_WEAPON_SCRIPTS[weapon_id]))
	player.add_child(weapon_node)
	_weapons_by_id[weapon_id] = weapon_node

func _apply_damage_buff(multiplier: float) -> void:
	for w in _weapons_by_id.values():
		if "damage" in w:
			w.damage *= multiplier

## Limit Break: double all weapon damage, halve all cooldowns, show screen flash.
func _activate_limit_break() -> void:
	player.damage_multiplier *= 2.0
	_apply_damage_buff(2.0)
	for w in _weapons_by_id.values():
		if "cooldown" in w:
			w.cooldown = max(0.1, w.cooldown * 0.5)
	var flash: Node = load("res://scripts/screen_flash.gd").new()
	get_tree().root.add_child(flash)

## Evolution: triple damage, boost speed, full heal, play 2-second cutscene.
func _activate_evolution() -> void:
	player.damage_multiplier *= 3.0
	player.speed_multiplier *= 1.5
	player.max_health *= 1.5
	player.heal(player.max_health)
	_apply_damage_buff(3.0)
	var cutscene: Node = load("res://scripts/evolution_cutscene.gd").new()
	get_tree().root.add_child(cutscene)

func increment_kill() -> void:
	kill_count += 1
	hud.update_kills(kill_count)
