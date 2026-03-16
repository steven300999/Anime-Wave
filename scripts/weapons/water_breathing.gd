## Water Breathing — Demon Slayer sword slash waves radiating outward
## in multiple directions, dealing high damage in a wide arc.
## Each upgrade level fires more slashes with greater damage.
##   Level 1: 8 directions,  35 dmg, 2.0s cooldown
##   Level 2: 8 directions,  50 dmg, 1.5s cooldown  (Water Wheel)
##   Level 3: 16 directions, 65 dmg, 1.2s cooldown  (Constant Flux)
extends WeaponBase

const SLASH_SCENE := preload("res://scenes/weapons/water_breathing_slash.tscn")

var ability_level := 1
var _directions := 8

func _ready() -> void:
	super()
	weapon_name = "Water Breathing"
	cooldown = 2.0
	damage = 35.0

func upgrade(new_level: int) -> void:
	ability_level = new_level
	match ability_level:
		2:
			cooldown = 1.5
			damage = 50.0
		3:
			_directions = 16
			cooldown = 1.2
			damage = 65.0

# Override to fire without needing a target (radiates in all directions)
func _process(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		fire(null)
		_cooldown_timer = cooldown

func fire(_target: Node2D) -> void:
	for i in _directions:
		var angle := i * TAU / _directions
		var dir := Vector2(cos(angle), sin(angle))
		var slash: Node2D = SLASH_SCENE.instantiate()
		slash.global_position = _player.global_position
		slash.setup(dir, damage)
		_get_game_root().add_child(slash)
