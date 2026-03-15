## Water Breathing — Demon Slayer sword slash waves radiating outward
## in 8 directions, dealing high damage in a wide arc.
extends WeaponBase

const SLASH_SCENE := preload("res://scenes/weapons/water_breathing_slash.tscn")
const DIRECTIONS := 8

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
	for i in DIRECTIONS:
		var angle := i * TAU / DIRECTIONS
		var dir := Vector2(cos(angle), sin(angle))
		var slash: Node2D = SLASH_SCENE.instantiate()
		slash.global_position = _player.global_position
		slash.setup(dir, damage)
		_get_game_root().add_child(slash)
