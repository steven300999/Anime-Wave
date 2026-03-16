## Water Breathing — Demon Slayer sword slash waves radiating outward
## in multiple directions, dealing high damage in a wide arc.
## Supports 7-tier progression: levels 2-5 are stat upgrades, level 6 is the
## Hinokami Kagura Limit Break, and level 7 is the Breath of the Sun Evolution.
extends WeaponBase

const SLASH_SCENE := preload("res://scenes/weapons/water_breathing_slash.tscn")

var _directions := 8

func _ready() -> void:
	super()
	weapon_name = "Water Breathing"
	cooldown = 2.0
	damage = 35.0

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

## Apply the stat changes for the given path level (2–7).
func upgrade(level: int) -> void:
	match level:
		2:
			damage += 5.0
			cooldown -= 0.25
		3: damage += 10.0
		4:
			damage += 10.0
			_directions = 12
		5: cooldown -= 0.25
		6:  # Limit Break — Hinokami Kagura
			_directions = 16
			cooldown = max(0.75, cooldown - 0.5)
			damage += 30.0
		7:  # Evolution — Breath of the Sun
			# _directions stays at 16 from Limit Break; Evolution differentiates
			# through doubled damage and a 0.5 s cooldown (frenetic, wall-of-blades pace).
			damage *= 2.0
			cooldown = 0.5
