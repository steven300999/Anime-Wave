extends Node2D

@onready var player = $Player
@onready var wave_manager = $WaveManager
@onready var hud = $UI
@onready var level_up_ui = $LevelUpUI
@onready var camera: Camera2D = $Camera2D

var kill_count := 0
var _weapons_by_id: Dictionary = {}

## Tracks the upgrade level of each ability path (0 = unowned, 1-5 = upgrades,
## 6 = Limit Break, 7 = Evolution). Used to gate upgrade / Limit Break / Evolution
## card offers in the level-up UI.
var path_levels: Dictionary = {}
var has_any_limit_break := false
var has_any_evolution := false

const _WEAPON_SCRIPTS := {
	"basic_shot": "res://scripts/weapons/basic_shot.gd",
	"rasengan": "res://scripts/weapons/rasengan.gd",
	"water_breathing": "res://scripts/weapons/water_breathing.gd",
	"cursed_energy": "res://scripts/weapons/cursed_energy.gd",
	"saitama_serious": "res://scripts/weapons/saitama_serious.gd",
	"genos_cannon": "res://scripts/weapons/genos_cannon.gd",
	"tatsumaki_lift": "res://scripts/weapons/tatsumaki_lift.gd",
	"bang_spiral": "res://scripts/weapons/bang_spiral.gd",
	"garou_fist": "res://scripts/weapons/garou_fist.gd",
}

## One Punch Man tiered paths that support 5 upgrades + Limit Break + Evolution.
const _OPM_PATHS := [
	"saitama_serious", "genos_cannon", "tatsumaki_lift", "bang_spiral", "garou_fist"
]

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
	level_up_ui.show_choices(level, path_levels, has_any_limit_break, has_any_evolution)

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

func _apply_damage_buff() -> void:
	for w in _weapons_by_id.values():
		if "damage" in w:
			w.damage *= 1.25

func increment_kill() -> void:
	kill_count += 1
	hud.update_kills(kill_count)
