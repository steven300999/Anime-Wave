extends Node2D

@onready var player = $Player
@onready var wave_manager = $WaveManager
@onready var hud = $UI
@onready var level_up_ui = $LevelUpUI
@onready var camera: Camera2D = $Camera2D

var kill_count := 0
# Tracks the current level of each ability (0 = not yet acquired)
var _ability_levels: Dictionary = {}
var _weapons_by_id: Dictionary = {}

const _WEAPON_SCRIPTS := {
	"basic_shot": "res://scripts/weapons/basic_shot.gd",
	"rasengan": "res://scripts/weapons/rasengan.gd",
	"water_breathing": "res://scripts/weapons/water_breathing.gd",
	"cursed_energy": "res://scripts/weapons/cursed_energy.gd",
	"zoro": "res://scripts/weapons/zoro.gd",
	"frieza": "res://scripts/weapons/frieza.gd",
	"goku": "res://scripts/weapons/goku.gd",
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
	level_up_ui.show_choices(level, _ability_levels)

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
	var new_level := _ability_levels.get(ability_id, 0) + 1
	_ability_levels[ability_id] = new_level

	if ability_id == "heal":
		player.heal(30.0)
	elif ability_id == "speed_up":
		player.speed_multiplier += 0.2
	elif ability_id == "damage_up":
		player.damage_multiplier += 0.25
		_apply_damage_buff()
	elif new_level == 1:
		# First time acquiring this weapon — add the node
		_give_weapon(ability_id)
		# Apply any accumulated damage boost to the freshly added weapon
		_sync_weapon_damage(_weapons_by_id.get(ability_id))
	else:
		# Upgrade an existing weapon to its new level
		_upgrade_weapon(ability_id, new_level)

func _give_weapon(weapon_id: String) -> void:
	if _weapons_by_id.has(weapon_id):
		return  # Already equipped
	if not _WEAPON_SCRIPTS.has(weapon_id):
		return
	var weapon_node := Node2D.new()
	weapon_node.set_script(load(_WEAPON_SCRIPTS[weapon_id]))
	player.add_child(weapon_node)
	_weapons_by_id[weapon_id] = weapon_node

func _upgrade_weapon(weapon_id: String, new_level: int) -> void:
	if not _weapons_by_id.has(weapon_id):
		return
	var weapon = _weapons_by_id[weapon_id]
	if weapon.has_method("upgrade"):
		weapon.upgrade(new_level)
	# After upgrade resets the weapon's base damage, reapply accumulated boosts
	_sync_weapon_damage(weapon)

func _apply_damage_buff() -> void:
	# Called each time damage_up is chosen: multiply all active weapons by 1.25
	for w in _weapons_by_id.values():
		if "damage" in w:
			w.damage *= 1.25

func _sync_weapon_damage(weapon) -> void:
	# Apply the full accumulated damage multiplier to a weapon's current base damage.
	# This is safe to call repeatedly because callers always reset the weapon's base
	# damage first (via _give_weapon or weapon.upgrade), so there is no compounding.
	if weapon == null:
		return
	var boost_count: int = _ability_levels.get("damage_up", 0)
	if "damage" in weapon and boost_count > 0:
		weapon.damage *= pow(1.25, boost_count)

func increment_kill() -> void:
	kill_count += 1
	hud.update_kills(kill_count)
