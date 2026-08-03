extends Node2D

@onready var player = $Player
@onready var wave_manager = $WaveManager
@onready var hud = $UI
@onready var level_up_ui = $LevelUpUI
@onready var camera: Camera2D = $Camera2D

const RIVAL_SCENE := preload("res://scenes/rival.tscn")
const ZONE_SCENE := preload("res://scenes/shrinking_zone.tscn")

const WEAPON_SCRIPTS := {
	"basic_shot": "res://scripts/weapons/basic_shot.gd",
	"rasengan": "res://scripts/weapons/rasengan.gd",
	"water_breathing": "res://scripts/weapons/water_breathing.gd",
	"cursed_energy": "res://scripts/weapons/cursed_energy.gd",
}

var kill_count := 0
var path_levels: Dictionary = {}
var has_evolution := false
var _weapons_by_id: Dictionary = {}
var _zone: Node2D = null
var _match_finished := false

func _ready() -> void:
	player.health_changed.connect(hud.update_health)
	player.exp_changed.connect(hud.update_exp)
	player.leveled_up.connect(_on_player_leveled_up)
	player.died.connect(_on_player_died)

	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.all_enemies_killed.connect(_on_all_enemies_killed)
	wave_manager.enemy_killed.connect(increment_kill)

	level_up_ui.ability_chosen.connect(_on_ability_chosen)

	camera.add_to_group("main_camera")
	hud.update_health(player.current_health, player.max_health)
	hud.update_exp(0, player.exp_required)
	hud.update_level(1)

	for style_id in StyleData.STYLE_ORDER:
		path_levels[style_id] = 0

	_give_weapon("basic_shot")
	_configure_mode()
	_setup_background()

func _process(_delta: float) -> void:
	if is_instance_valid(player):
		camera.global_position = player.global_position
	if _is_multiplayer_mode() and not _match_finished:
		_update_remaining_players()

func _configure_mode() -> void:
	if _is_multiplayer_mode():
		hud.set_mode(GameBalance.UI["multiplayer_mode_label"], true)
		wave_manager.stop()
		player.add_to_group("combatants")
		_spawn_rivals(GameBalance.MULTI["rival_count"])
		_setup_shrinking_zone()
	else:
		hud.set_mode(GameBalance.UI["single_mode_label"], false)
		wave_manager.start()

func _is_multiplayer_mode() -> bool:
	var settings := get_node_or_null("/root/SessionSettings")
	return settings != null and settings.is_multiplayer_mode()

func _setup_background() -> void:
	pass

func _on_player_leveled_up(level: int) -> void:
	hud.update_level(level)
	level_up_ui.show_choices(level, path_levels, has_evolution)

func _on_player_died() -> void:
	if _is_multiplayer_mode():
		_end_multiplayer_match(false)
		return
	await get_tree().create_timer(0.8).timeout
	_show_game_over(false)

func _on_wave_started(wave: int) -> void:
	if not _is_multiplayer_mode():
		hud.update_wave(wave)

func _on_all_enemies_killed() -> void:
	pass

func _on_ability_chosen(ability_id: String) -> void:
	if StyleData.is_style(ability_id):
		var current_level: int = path_levels.get(ability_id, 0)
		var new_level := min(7, current_level + 1)
		path_levels[ability_id] = new_level
		_apply_style_upgrade(ability_id, new_level)
		if new_level == 7:
			has_evolution = true
		return

	match ability_id:
		"heal":
			player.heal(30.0)
		"speed_up":
			player.speed_multiplier += 0.2
		"damage_up":
			_apply_damage_buff()

func _apply_style_upgrade(style_id: String, level: int) -> void:
	var weapon_id := StyleData.weapon_id_for_style(style_id)
	if weapon_id.is_empty():
		return
	if level == 1:
		_give_weapon(weapon_id)
		return
	_upgrade_weapon(weapon_id, level)

	var weapon = _weapons_by_id.get(weapon_id, null)
	if not is_instance_valid(weapon):
		return

	if level == 7:
		match style_id:
			"maruto":
				player.speed_multiplier += 0.8
			"panjiro":
				if "cooldown" in weapon:
					weapon.cooldown = max(0.35, weapon.cooldown * 0.8)
			"itabro":
				if "projectile_speed" in weapon:
					weapon.projectile_speed += 80.0

func _give_weapon(weapon_id: String) -> void:
	if _weapons_by_id.has(weapon_id):
		return
	if not WEAPON_SCRIPTS.has(weapon_id):
		return
	var weapon_node := Node2D.new()
	weapon_node.set_script(load(WEAPON_SCRIPTS[weapon_id]))
	player.add_child(weapon_node)
	_weapons_by_id[weapon_id] = weapon_node

func _upgrade_weapon(weapon_id: String, level: int) -> void:
	if not _weapons_by_id.has(weapon_id):
		return
	var weapon: Node = _weapons_by_id[weapon_id]
	if weapon.has_method("upgrade"):
		weapon.upgrade(level)

func _apply_damage_buff() -> void:
	player.damage_multiplier += 0.25
	for w in _weapons_by_id.values():
		if "damage" in w:
			w.damage *= 1.25

func increment_kill() -> void:
	kill_count += 1
	hud.update_kills(kill_count)

func _spawn_rivals(count: int) -> void:
	var radius := GameBalance.MULTI["arena_start_radius"] * 0.75
	for i in count:
		var rival: Node2D = RIVAL_SCENE.instantiate()
		var angle := float(i) / float(max(1, count)) * TAU
		rival.global_position = Vector2(cos(angle), sin(angle)) * radius
		rival.eliminated.connect(_on_rival_eliminated)
		add_child(rival)
	_update_remaining_players()

func _on_rival_eliminated(_rival: Node) -> void:
	increment_kill()
	_update_remaining_players()

func _update_remaining_players() -> void:
	var alive := 0
	for node in get_tree().get_nodes_in_group("combatants"):
		if is_instance_valid(node):
			alive += 1
	hud.update_remaining_players(alive)
	if alive <= 1:
		_end_multiplayer_match(is_instance_valid(player) and player.visible)

func _setup_shrinking_zone() -> void:
	_zone = ZONE_SCENE.instantiate()
	add_child(_zone)
	_zone.center = Vector2.ZERO
	_zone.configure(GameBalance.MULTI)
	_zone.zone_updated.connect(_on_zone_updated)

func _on_zone_updated(radius: float, progress: float) -> void:
	hud.update_zone_status(radius, progress)

func _end_multiplayer_match(player_won: bool) -> void:
	if _match_finished:
		return
	_match_finished = true
	await get_tree().create_timer(0.8).timeout
	_show_game_over(player_won)

func _show_game_over(player_won: bool) -> void:
	var game_over: Node = load("res://scenes/game_over.tscn").instantiate()
	var mode_name := "Multiplayer LMS" if _is_multiplayer_mode() else "Single PvE"
	game_over.setup(kill_count, hud.get_elapsed(), player.level, player_won, mode_name)
	get_tree().root.add_child(game_over)
	queue_free()
