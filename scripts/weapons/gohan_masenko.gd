## Masenko — Gohan's overhead energy blast launched toward the nearest enemy.
## Fires a wide fan of energy waves that can hit multiple targets. The path of
## Potential awakens as Gohan's hidden power grows, ultimately reaching
## Gohan Beast.
extends WeaponBase

const _PROJ := preload("res://scripts/weapons/dragon_ball_projectile.gd")

var wave_count := 3

func _ready() -> void:
	super()
	weapon_name = "Masenko"
	cooldown = 1.5
	damage = 28.0
	projectile_speed = 300.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	for i in wave_count:
		var spread := 0.0
		if wave_count > 1:
			spread = (float(i) / float(max(wave_count - 1, 1)) - 0.5) * 0.5
		var dir := base_dir.rotated(spread)
		var proj := Node2D.new()
		proj.set_script(_PROJ)
		proj.global_position = _player.global_position
		proj.setup(dir, damage, projectile_speed,
				Color(0.8, 0.2, 1.0), Color(1.0, 0.8, 0.2), 10.0)
		_get_game_root().add_child(proj)
