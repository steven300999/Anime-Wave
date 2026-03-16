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
	# Dragon Ball universe
	"ki_blast": "res://scripts/weapons/ki_blast.gd",
	"pride_strike": "res://scripts/weapons/pride_strike.gd",
	"gohan_masenko": "res://scripts/weapons/gohan_masenko.gd",
	"namekian_arm": "res://scripts/weapons/namekian_arm.gd",
	"death_beam": "res://scripts/weapons/death_beam.gd",
}

## Upgrade effects for Dragon Ball path abilities.
## Keys: ability_id. Values: weapon to target + numeric modifiers.
##   dmg  — multiply weapon.damage by this factor
##   cd   — multiply weapon.cooldown by this factor
##   shot_count / wave_count / arm_count / beam_count — set that property
##   heal — restore this many HP to the player
const _DRAGON_BALL_UPGRADES := {
	# Goku (Ki path)
	"ki_1":          {"weapon": "ki_blast",    "dmg": 1.20, "cd": 0.85},
	"ki_2":          {"weapon": "ki_blast",    "dmg": 1.25, "shot_count": 2},
	"ki_3":          {"weapon": "ki_blast",    "dmg": 1.50, "cd": 0.90},
	"ki_4":          {"weapon": "ki_blast",    "dmg": 1.50},
	"ki_5":          {"weapon": "ki_blast",    "dmg": 1.80, "shot_count": 3},
	"ki_limit_break":{"weapon": "ki_blast",    "dmg": 2.00, "cd": 0.70},
	"ultra_instinct":{"weapon": "ki_blast",    "dmg": 3.00, "cd": 0.50},
	# Vegeta (Pride path)
	"pride_1":          {"weapon": "pride_strike", "dmg": 1.20, "cd": 0.90},
	"pride_2":          {"weapon": "pride_strike", "dmg": 1.25},
	"pride_3":          {"weapon": "pride_strike", "dmg": 1.40, "cd": 0.85},
	"pride_4":          {"weapon": "pride_strike", "dmg": 1.60},
	"pride_5":          {"weapon": "pride_strike", "dmg": 1.50, "shot_count": 5},
	"pride_limit_break":{"weapon": "pride_strike", "dmg": 2.00, "cd": 0.70},
	"ssb_evolved":      {"weapon": "pride_strike", "dmg": 3.00, "cd": 0.55},
	# Gohan (Potential path)
	"gohan_1":          {"weapon": "gohan_masenko", "dmg": 1.20},
	"gohan_2":          {"weapon": "gohan_masenko", "dmg": 1.25, "wave_count": 5},
	"gohan_3":          {"weapon": "gohan_masenko", "dmg": 1.40, "cd": 0.85},
	"gohan_4":          {"weapon": "gohan_masenko", "dmg": 1.60},
	"gohan_5":          {"weapon": "gohan_masenko", "dmg": 1.50, "wave_count": 7},
	"gohan_limit_break":{"weapon": "gohan_masenko", "dmg": 2.00, "cd": 0.70},
	"gohan_beast":      {"weapon": "gohan_masenko", "dmg": 3.00, "cd": 0.60, "wave_count": 9},
	# Piccolo (Namekian path)
	"namekian_1":          {"weapon": "namekian_arm", "dmg": 1.20},
	"namekian_2":          {"weapon": "namekian_arm", "dmg": 1.25},
	"namekian_3":          {"weapon": "namekian_arm", "dmg": 1.40, "heal": 30.0},
	"namekian_4":          {"weapon": "namekian_arm", "dmg": 1.50, "arm_count": 2},
	"namekian_5":          {"weapon": "namekian_arm", "dmg": 1.50, "arm_count": 3},
	"namekian_limit_break":{"weapon": "namekian_arm", "dmg": 2.00},
	"unlocked_namekian":   {"weapon": "namekian_arm", "dmg": 3.00, "arm_count": 4},
	# Frieza (Tyrant path)
	"tyrant_1":          {"weapon": "death_beam", "dmg": 1.20, "cd": 0.85},
	"tyrant_2":          {"weapon": "death_beam", "dmg": 1.25, "cd": 0.80},
	"tyrant_3":          {"weapon": "death_beam", "dmg": 1.50},
	"tyrant_4":          {"weapon": "death_beam", "dmg": 1.60, "cd": 0.75},
	"tyrant_5":          {"weapon": "death_beam", "dmg": 1.50, "beam_count": 3},
	"tyrant_limit_break":{"weapon": "death_beam", "dmg": 2.00, "cd": 0.65},
	"black_frieza":      {"weapon": "death_beam", "dmg": 3.00, "cd": 0.45},
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
	elif ability_id in _DRAGON_BALL_UPGRADES:
		_apply_dragon_ball_upgrade(ability_id)
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

func _apply_dragon_ball_upgrade(ability_id: String) -> void:
	var eff: Dictionary = _DRAGON_BALL_UPGRADES[ability_id]
	var weapon_id: String = eff["weapon"]
	if not _weapons_by_id.has(weapon_id):
		return
	var w = _weapons_by_id[weapon_id]
	if eff.has("dmg"):
		w.damage *= float(eff["dmg"])
	if eff.has("cd"):
		w.cooldown *= float(eff["cd"])
	if eff.has("shot_count") and "shot_count" in w:
		w.shot_count = int(eff["shot_count"])
	if eff.has("wave_count") and "wave_count" in w:
		w.wave_count = int(eff["wave_count"])
	if eff.has("arm_count") and "arm_count" in w:
		w.arm_count = int(eff["arm_count"])
	if eff.has("beam_count") and "beam_count" in w:
		w.beam_count = int(eff["beam_count"])
	if eff.has("heal"):
		player.heal(float(eff["heal"]))

func increment_kill() -> void:
	kill_count += 1
	hud.update_kills(kill_count)
