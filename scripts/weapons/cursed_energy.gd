## Cursed Energy Blast — JJK-style projectile burst fired toward the
## nearest enemy, fanning out multiple bolts.
## Supports 7-tier progression: levels 2-5 are stat upgrades, level 6 is the
## Black Flash Limit Break, and level 7 is the Domain Expansion Evolution
## (omnidirectional bolt storm).
extends WeaponBase

const BLAST_SCENE := preload("res://scenes/weapons/cursed_energy_blast.tscn")

var _bolt_count := 5
var _spread_angle := PI / 6.0  # 30° total fan

func _ready() -> void:
	super()
	weapon_name = "Cursed Energy Blast"
	cooldown = 1.5
	damage = 20.0
	projectile_speed = 320.0

# Override _process so Domain Expansion can fire without a target.
func _process(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		var target := _get_target()
		if target != null or _spread_angle >= TAU:
			fire(target)
			_cooldown_timer = cooldown

func fire(target: Node2D) -> void:
	var base_angle := 0.0
	if target != null:
		base_angle = _player.global_position.direction_to(target.global_position).angle()
	for i in _bolt_count:
		var angle: float
		if _spread_angle >= TAU:
			# Domain Expansion: evenly distribute bolts around full circle
			angle = base_angle + float(i) / float(_bolt_count) * TAU
		else:
			# Divide evenly across the fan; guard against _bolt_count == 1 (no division by zero).
			var t := float(i) / float(_bolt_count - 1) - 0.5 if _bolt_count > 1 else 0.0
			angle = base_angle + t * _spread_angle
		var dir := Vector2(cos(angle), sin(angle))
		var bolt: Node2D = BLAST_SCENE.instantiate()
		bolt.global_position = _player.global_position
		bolt.setup(dir, damage, projectile_speed)
		_get_game_root().add_child(bolt)

## Apply the stat changes for the given path level (2–7).
func upgrade(level: int) -> void:
	match level:
		2:
			_bolt_count += 1
			damage += 5.0
		3:
			damage += 5.0
			_spread_angle = PI / 4.0
		4:
			_bolt_count += 1
			damage += 10.0
		5:
			damage += 5.0
			projectile_speed += 50.0
		6:  # Limit Break — Black Flash
			_bolt_count *= 2
			damage *= 1.5
		7:  # Evolution — Domain Expansion
			_bolt_count = 20
			_spread_angle = TAU
			damage *= 2.0
			projectile_speed += 50.0
