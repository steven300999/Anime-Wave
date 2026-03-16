## Genos – Incineration Cannon (One Punch Man)
## Fires concentrated fire bolts toward the nearest enemy.
## Upgrade path: 5 levels → Limit Break → Demon Cyborg Full Upgrade (Evolution).
extends WeaponBase

const BEAM_SCENE := preload("res://scenes/weapons/genos_beam.tscn")

var _bolt_count := 3
var _spread := PI / 8.0

func _ready() -> void:
	super()
	weapon_name = "Incineration Cannon"
	cooldown = 1.5
	damage = 30.0
	projectile_speed = 350.0

func upgrade(level: int) -> void:
	match level:
		2: damage = 38.0;  cooldown = 1.3
		3: damage = 47.0;  cooldown = 1.1; projectile_speed = 380.0
		4: damage = 58.0;  cooldown = 1.0; _bolt_count = 5
		5: damage = 72.0;  cooldown = 0.85; _spread = PI / 6.0
		6: damage = 120.0; cooldown = 0.7; _bolt_count = 7; projectile_speed = 420.0
		7: damage = 180.0; cooldown = 0.5; _bolt_count = 9; _spread = PI / 5.0; projectile_speed = 460.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	var base_angle := base_dir.angle()
	for i in _bolt_count:
		var t := 0.0 if _bolt_count == 1 else float(i) / float(_bolt_count - 1) - 0.5
		var angle := base_angle + t * _spread
		var dir := Vector2(cos(angle), sin(angle))
		var beam: Node2D = BEAM_SCENE.instantiate()
		beam.global_position = _player.global_position
		beam.setup(dir, damage, projectile_speed)
		_get_game_root().add_child(beam)
