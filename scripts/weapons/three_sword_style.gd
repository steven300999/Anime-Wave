## Three Sword Style — Zoro fires sword slashes in a fan toward the nearest enemy.
## Upgrades widen the fan and boost damage. Limit Break (Asura) fills 360°.
## Evolution (King of Hell): black-blade slashes with massive damage.
extends WeaponBase

const SLASH_SCENE := preload("res://scenes/weapons/three_sword_slash.tscn")

var _slash_count := 3
var _spread := PI / 6.0  # angular spacing between adjacent slashes in the fan
var _black_blade := false

func _ready() -> void:
	super()
	weapon_name = "Three Sword Style"
	cooldown = 1.4
	damage = 30.0

func fire(target: Node2D) -> void:
	var base_angle := _player.global_position.direction_to(target.global_position).angle()
	var half := (_slash_count - 1) / 2.0
	for i in _slash_count:
		var angle := base_angle + (i - half) * _spread
		var dir := Vector2(cos(angle), sin(angle))
		var slash: Node2D = SLASH_SCENE.instantiate()
		slash.global_position = _player.global_position
		slash.setup(dir, damage, _black_blade)
		_get_game_root().add_child(slash)

func upgrade(level: int) -> void:
	match level:
		1:
			damage += 8.0
			cooldown = maxf(1.1, cooldown - 0.1)
		2:
			_slash_count = 5
			damage += 6.0
		3:
			damage += 10.0
			cooldown = maxf(0.85, cooldown - 0.1)
		4:
			_slash_count = 7
			damage += 10.0
		5:
			damage += 12.0
			cooldown = maxf(0.65, cooldown - 0.1)
			_slash_count += 2

func activate_limit_break() -> void:
	damage *= 1.7
	cooldown = maxf(0.5, cooldown - 0.2)
	_slash_count = 9  # Asura — nine-sword phantasm

func activate_evolution() -> void:
	weapon_name = "King of Hell"
	_black_blade = true
	damage *= 2.2
	cooldown = 0.4
	_slash_count = 12
