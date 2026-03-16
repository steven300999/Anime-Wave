## Garou – Monster Fist (One Punch Man)
## Launches rapid bone-crushing fists toward enemies.
## Upgrade path: 5 levels → Limit Break → Awakened Garou God (Evolution).
extends WeaponBase

const PUNCH_SCENE := preload("res://scenes/weapons/garou_punch.tscn")

var _punch_count := 3
var _spread := PI / 10.0

func _ready() -> void:
	super()
	weapon_name = "Monster Fist"
	cooldown = 1.2
	damage = 20.0
	projectile_speed = 400.0

func upgrade(level: int) -> void:
	match level:
		2: damage = 26.0; cooldown = 1.0;  _punch_count = 4
		3: damage = 33.0; cooldown = 0.9;  projectile_speed = 430.0
		4: damage = 42.0; cooldown = 0.8;  _punch_count = 5
		5: damage = 54.0; cooldown = 0.7;  projectile_speed = 470.0
		6: damage = 90.0; cooldown = 0.55; _punch_count = 7; projectile_speed = 500.0
		7: damage = 140.0; cooldown = 0.4; _punch_count = 10; _spread = PI / 4.0; projectile_speed = 550.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	var base_angle := base_dir.angle()
	for i in _punch_count:
		var t := 0.0 if _punch_count == 1 else float(i) / float(_punch_count - 1) - 0.5
		var angle := base_angle + t * _spread
		var dir := Vector2(cos(angle), sin(angle))
		var punch: Node2D = PUNCH_SCENE.instantiate()
		punch.global_position = _player.global_position
		punch.setup(dir, damage, projectile_speed)
		_get_game_root().add_child(punch)
