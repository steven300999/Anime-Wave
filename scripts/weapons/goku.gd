## Goku (Dragon Ball Z) — Kamehameha: powerful blue ki waves fired toward
## the nearest enemy, gaining more waves and power with each upgrade level.
##   Level 1 — Kamehameha:        1 wave,  35 dmg, 1.8s cooldown
##   Level 2 — Super Kamehameha:  3 waves, 50 dmg, 1.5s cooldown
##   Level 3 — Limit Break:       5 waves, 70 dmg, 1.0s cooldown
extends WeaponBase

const WAVE_SCENE := preload("res://scenes/weapons/goku_wave.tscn")

var ability_level := 1

func _ready() -> void:
	super()
	weapon_name = "Kamehameha"
	_apply_level()

func _apply_level() -> void:
	match ability_level:
		1:
			cooldown = 1.8
			damage = 35.0
			projectile_speed = 360.0
		2:
			cooldown = 1.5
			damage = 50.0
			projectile_speed = 390.0
		3:
			cooldown = 1.0
			damage = 70.0
			projectile_speed = 430.0

func upgrade(new_level: int) -> void:
	ability_level = new_level
	_apply_level()

func _get_wave_count() -> int:
	match ability_level:
		1: return 1
		2: return 3
		3: return 5
		_: return 1

func _get_spread() -> float:
	match ability_level:
		1: return 0.0
		2: return PI / 7.0
		3: return PI / 5.0
		_: return 0.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	var base_angle := base_dir.angle()
	var count := _get_wave_count()
	var spread := _get_spread()
	for i in count:
		var t := 0.0 if count == 1 else float(i) / float(count - 1) - 0.5
		var angle := base_angle + t * spread
		var dir := Vector2(cos(angle), sin(angle))
		var wave: Node2D = WAVE_SCENE.instantiate()
		wave.global_position = _player.global_position
		wave.setup(dir, damage, projectile_speed)
		_get_game_root().add_child(wave)
