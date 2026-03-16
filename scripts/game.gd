extends Node2D

@onready var player = $Player
@onready var wave_manager = $WaveManager
@onready var hud = $UI
@onready var level_up_ui = $LevelUpUI
@onready var camera: Camera2D = $Camera2D

var kill_count := 0
var _owned_abilities: Array[String] = []
var _weapons_by_id: Dictionary = {}

# Active One Piece path (base-weapon ID) and the weapon node for it
var _op_path_id := ""

const _WEAPON_SCRIPTS := {
	"basic_shot": "res://scripts/weapons/basic_shot.gd",
	"rasengan": "res://scripts/weapons/rasengan.gd",
	"water_breathing": "res://scripts/weapons/water_breathing.gd",
	"cursed_energy": "res://scripts/weapons/cursed_energy.gd",
	# One Piece
	"luffy_gum_gum": "res://scripts/weapons/gum_gum_pistol.gd",
	"zoro_three_sword": "res://scripts/weapons/three_sword_style.gd",
	"sanji_black_leg": "res://scripts/weapons/black_leg.gd",
	"nami_weather": "res://scripts/weapons/weather_staff.gd",
	"robin_devil_fruit": "res://scripts/weapons/devil_fruit_bloom.gd",
}

# Upgrade-level chain for each One Piece path (indices 0-4 → levels 2-6)
const _OP_UPGRADES := {
	"luffy_gum_gum":    ["luffy_up_1", "luffy_up_2", "luffy_up_3", "luffy_up_4", "luffy_up_5"],
	"zoro_three_sword": ["zoro_up_1",  "zoro_up_2",  "zoro_up_3",  "zoro_up_4",  "zoro_up_5"],
	"sanji_black_leg":  ["sanji_up_1", "sanji_up_2", "sanji_up_3", "sanji_up_4", "sanji_up_5"],
	"nami_weather":     ["nami_up_1",  "nami_up_2",  "nami_up_3",  "nami_up_4",  "nami_up_5"],
	"robin_devil_fruit":["robin_up_1", "robin_up_2", "robin_up_3", "robin_up_4", "robin_up_5"],
}

const _OP_LIMIT_BREAKS := {
	"luffy_gum_gum":    "luffy_lb",
	"zoro_three_sword": "zoro_lb",
	"sanji_black_leg":  "sanji_lb",
	"nami_weather":     "nami_lb",
	"robin_devil_fruit":"robin_lb",
}

const _OP_EVOLUTIONS := {
	"luffy_gum_gum":    "luffy_evo",
	"zoro_three_sword": "zoro_evo",
	"sanji_black_leg":  "sanji_evo",
	"nami_weather":     "nami_evo",
	"robin_devil_fruit":"robin_evo",
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
		_apply_damage_buff()
	elif _WEAPON_SCRIPTS.has(ability_id):
		_give_weapon(ability_id)
		# Track the active One Piece path if this is an OP base weapon
		if _OP_UPGRADES.has(ability_id):
			_op_path_id = ability_id
	else:
		_handle_op_progression(ability_id)
	_owned_abilities.append(ability_id)

## Apply an OP upgrade, limit break, or evolution to the active path weapon.
func _handle_op_progression(ability_id: String) -> void:
	if _op_path_id.is_empty():
		return
	var weapon_node = _weapons_by_id.get(_op_path_id)
	if not is_instance_valid(weapon_node):
		return
	# Check for upgrade
	var upgrades: Array = _OP_UPGRADES.get(_op_path_id, [])
	var up_idx := upgrades.find(ability_id)
	if up_idx >= 0:
		if weapon_node.has_method("upgrade"):
			weapon_node.upgrade(up_idx + 1)  # levels 1-5
		return
	# Check for limit break
	if _OP_LIMIT_BREAKS.get(_op_path_id, "") == ability_id:
		if weapon_node.has_method("activate_limit_break"):
			weapon_node.activate_limit_break()
		return
	# Check for evolution
	if _OP_EVOLUTIONS.get(_op_path_id, "") == ability_id:
		if weapon_node.has_method("activate_evolution"):
			weapon_node.activate_evolution()

func _give_weapon(weapon_id: String) -> void:
	if _weapons_by_id.has(weapon_id):
		return  # Already equipped
	if not _WEAPON_SCRIPTS.has(weapon_id):
		return
	var weapon_node := Node2D.new()
	weapon_node.set_script(load(_WEAPON_SCRIPTS[weapon_id]))
	player.add_child(weapon_node)
	_weapons_by_id[weapon_id] = weapon_node

func _apply_damage_buff() -> void:
	for w in _weapons_by_id.values():
		if "damage" in w:
			w.damage *= 1.25

func increment_kill() -> void:
	kill_count += 1
	hud.update_kills(kill_count)
