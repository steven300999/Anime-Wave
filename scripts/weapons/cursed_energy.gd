## Cursed Energy Blast — JJK-style projectile burst fired toward the
## nearest enemy, fanning out multiple bolts. Each upgrade level adds
## more bolts and increases damage.
##   Level 1: 5 bolts, 20 dmg, 1.5s cooldown
##   Level 2: 7 bolts, 30 dmg, 1.2s cooldown
##   Level 3: 9 bolts, 45 dmg, 0.9s cooldown
extends WeaponBase

const BLAST_SCENE := preload("res://scenes/weapons/cursed_energy_blast.tscn")
const SPREAD_ANGLE := PI / 6.0  # 30° total fan

var ability_level := 1
var _bolt_count := 5

func _ready() -> void:
	super()
	weapon_name = "Cursed Energy Blast"
	cooldown = 1.5
	damage = 20.0
	projectile_speed = 320.0

func upgrade(new_level: int) -> void:
	ability_level = new_level
	match ability_level:
		2:
			_bolt_count = 7
			cooldown = 1.2
			damage = 30.0
		3:
			_bolt_count = 9
			cooldown = 0.9
			damage = 45.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	var base_angle := base_dir.angle()
	for i in _bolt_count:
		var t := float(i) / float(_bolt_count - 1) - 0.5  # -0.5 to 0.5
		var angle := base_angle + t * SPREAD_ANGLE
		var dir := Vector2(cos(angle), sin(angle))
		var bolt: Node2D = BLAST_SCENE.instantiate()
		bolt.global_position = _player.global_position
		bolt.setup(dir, damage, projectile_speed)
		_get_game_root().add_child(bolt)
