## Black Leg — Sanji fires rapid kick blasts in a forward arc.
## Upgrades widen the arc and ignite kicks (Diable Jambe).
## Limit Break: burning barrage. Evolution (Raid Suit): invisible ultra-speed kicks.
extends WeaponBase

const KICK_SCENE := preload("res://scenes/weapons/black_leg_kick.tscn")

var _bolt_count := 3
var _spread := PI / 5.0  # total arc width
var _flaming := false

func _ready() -> void:
	super()
	weapon_name = "Black Leg"
	cooldown = 0.7
	damage = 22.0
	projectile_speed = 420.0

func fire(target: Node2D) -> void:
	var base_angle := _player.global_position.direction_to(target.global_position).angle()
	for i in _bolt_count:
		var t := 0.0 if _bolt_count == 1 else float(i) / float(_bolt_count - 1) - 0.5
		var angle := base_angle + t * _spread
		var dir := Vector2(cos(angle), sin(angle))
		var kick: Node2D = KICK_SCENE.instantiate()
		kick.global_position = _player.global_position
		kick.setup(dir, damage, projectile_speed, _flaming)
		_get_game_root().add_child(kick)

func upgrade(level: int) -> void:
	match level:
		1:
			damage += 5.0
			cooldown = maxf(0.55, cooldown - 0.05)
		2:
			_bolt_count = 4
			damage += 5.0
		3:
			_flaming = true
			damage += 8.0
		4:
			_bolt_count = 5
			cooldown = maxf(0.4, cooldown - 0.05)
			damage += 6.0
		5:
			damage += 8.0
			cooldown = maxf(0.3, cooldown - 0.05)
			_bolt_count += 1

func activate_limit_break() -> void:
	damage *= 1.5
	cooldown = maxf(0.2, cooldown - 0.15)
	_bolt_count += 2
	_flaming = true

func activate_evolution() -> void:
	weapon_name = "Raid Suit"
	damage *= 2.0
	cooldown = 0.15
	_bolt_count = 8
	projectile_speed = 600.0
	_flaming = true
