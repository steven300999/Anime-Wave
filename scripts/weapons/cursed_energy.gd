## Cursed Energy Blast — JJK-style projectile burst fired toward the
## nearest enemy, fanning out multiple bolts.
extends WeaponBase

const BLAST_SCENE := preload("res://scenes/weapons/cursed_energy_blast.tscn")
const BOLT_COUNT := 5
const SPREAD_ANGLE := PI / 6.0  # 30° total fan

func _ready() -> void:
	super()
	weapon_name = "Cursed Energy Blast"
	cooldown = 1.5
	damage = 20.0
	projectile_speed = 320.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	var base_angle := base_dir.angle()
	for i in BOLT_COUNT:
		var t := float(i) / float(BOLT_COUNT - 1) - 0.5  # -0.5 to 0.5
		var angle := base_angle + t * SPREAD_ANGLE
		var dir := Vector2(cos(angle), sin(angle))
		var bolt: Node2D = BLAST_SCENE.instantiate()
		bolt.global_position = _player.global_position
		bolt.setup(dir, damage, projectile_speed)
		_get_game_root().add_child(bolt)
