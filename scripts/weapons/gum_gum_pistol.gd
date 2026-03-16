## Gum Gum Pistol — Luffy's rubber-arm projectile attack.
## Upgrades increase bullet count and damage. Limit Break boosts stats.
## Evolution (Gear Fifth): cartoonish max-power barrage.
extends WeaponBase

const BULLET_SCENE := preload("res://scenes/weapons/gum_gum_bullet.tscn")
const BULLET_SPREAD_ANGLE := 0.15  # half total arc width in radians

var _bullet_count := 1

func _ready() -> void:
	super()
	weapon_name = "Gum Gum Pistol"
	cooldown = 0.9
	damage = 18.0
	projectile_speed = 350.0

func fire(target: Node2D) -> void:
	var base_angle := _player.global_position.direction_to(target.global_position).angle()
	var spread := BULLET_SPREAD_ANGLE
	for i in _bullet_count:
		var t := 0.0 if _bullet_count == 1 else float(i) / float(_bullet_count - 1) - 0.5
		var angle := base_angle + t * spread * 2.0
		var dir := Vector2(cos(angle), sin(angle))
		var bullet: Node2D = BULLET_SCENE.instantiate()
		bullet.global_position = _player.global_position
		bullet.setup(dir, damage, projectile_speed)
		_get_game_root().add_child(bullet)

func upgrade(level: int) -> void:
	match level:
		1:
			damage += 5.0
			cooldown = maxf(0.65, cooldown - 0.05)
		2:
			_bullet_count = 2
			damage += 5.0
		3:
			damage += 8.0
			cooldown = maxf(0.55, cooldown - 0.05)
		4:
			_bullet_count = 3
			damage += 8.0
			projectile_speed += 50.0
		5:
			damage += 10.0
			cooldown = maxf(0.4, cooldown - 0.05)
			_bullet_count += 1

func activate_limit_break() -> void:
	damage *= 1.6
	cooldown = maxf(0.35, cooldown - 0.15)
	_bullet_count += 1

func activate_evolution() -> void:
	weapon_name = "Gear Fifth"
	damage *= 2.0
	cooldown = 0.25
	_bullet_count = 5
	projectile_speed = 500.0
