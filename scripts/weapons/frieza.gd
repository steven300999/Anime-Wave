## Frieza (Dragon Ball Z) — Death Beam: hot-pink ki beams fired toward the
## nearest enemy, gaining more beams and power with each upgrade level.
##   Level 1 — Death Beam:   1 beam,  28 dmg, 1.0s cooldown
##   Level 2 — Twin Beams:   2 beams, 35 dmg, 0.9s cooldown
##   Level 3 — Death Saucer: 3 beams, 45 dmg, 0.8s cooldown
##   Level 4 — Golden Form:  5 beams, 60 dmg, 0.6s cooldown
extends WeaponBase

const BEAM_SCENE := preload("res://scenes/weapons/frieza_beam.tscn")

var ability_level := 1

func _ready() -> void:
	super()
	weapon_name = "Frieza Death Beam"
	_apply_level()

func _apply_level() -> void:
	match ability_level:
		1:
			cooldown = 1.0
			damage = 28.0
			projectile_speed = 350.0
		2:
			cooldown = 0.9
			damage = 35.0
			projectile_speed = 370.0
		3:
			cooldown = 0.8
			damage = 45.0
			projectile_speed = 390.0
		4:
			cooldown = 0.6
			damage = 60.0
			projectile_speed = 420.0

func upgrade(new_level: int) -> void:
	ability_level = new_level
	_apply_level()

func _get_beam_count() -> int:
	match ability_level:
		1: return 1
		2: return 2
		3: return 3
		4: return 5
		_: return 1

func _get_spread() -> float:
	match ability_level:
		1: return 0.0
		2: return PI / 8.0
		3: return PI / 6.0
		4: return PI / 4.0
		_: return 0.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	var base_angle := base_dir.angle()
	var count := _get_beam_count()
	var spread := _get_spread()
	for i in count:
		var t := 0.0 if count == 1 else float(i) / float(count - 1) - 0.5
		var angle := base_angle + t * spread
		var dir := Vector2(cos(angle), sin(angle))
		var beam: Node2D = BEAM_SCENE.instantiate()
		beam.global_position = _player.global_position
		beam.setup(dir, damage, projectile_speed)
		_get_game_root().add_child(beam)
