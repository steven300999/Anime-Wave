## Zoro (One Piece) — Three Sword Style: sword slashes radiate in multiple
## directions. Each upgrade level increases the number of slashes and damage.
##   Level 1 — Oni Giri:     3 directions, 30 dmg, 2.5s cooldown
##   Level 2 — Tiger Hunt:   6 directions, 45 dmg, 2.0s cooldown
##   Level 3 — Hell's Memory: 8 directions, 65 dmg, 1.5s cooldown
extends WeaponBase

const SLASH_SCENE := preload("res://scenes/weapons/zoro_slash.tscn")

var ability_level := 1

func _ready() -> void:
	super()
	weapon_name = "Three Sword Style"
	_apply_level()

func _apply_level() -> void:
	match ability_level:
		1:
			cooldown = 2.5
			damage = 30.0
		2:
			cooldown = 2.0
			damage = 45.0
		3:
			cooldown = 1.5
			damage = 65.0

func upgrade(new_level: int) -> void:
	ability_level = new_level
	_apply_level()

func _get_slash_count() -> int:
	match ability_level:
		1: return 3
		2: return 6
		3: return 8
		_: return 3

# Override to fire without needing a target (radiates in all directions)
func _process(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		fire(null)
		_cooldown_timer = cooldown

func fire(_target: Node2D) -> void:
	var count := _get_slash_count()
	for i in count:
		var angle := i * TAU / count
		var dir := Vector2(cos(angle), sin(angle))
		var slash: Node2D = SLASH_SCENE.instantiate()
		slash.global_position = _player.global_position
		slash.setup(dir, damage)
		_get_game_root().add_child(slash)
