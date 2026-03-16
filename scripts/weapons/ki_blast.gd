## Ki Blast — Goku's rapid energy shots fired toward the nearest enemy.
## The path of Ki rises through training: base Saiyan → Super Saiyan →
## Super Saiyan Blue → Ultra Instinct.
extends WeaponBase

const _PROJ := preload("res://scripts/weapons/dragon_ball_projectile.gd")

var shot_count := 1

func _ready() -> void:
	super()
	weapon_name = "Ki Blast"
	cooldown = 0.7
	damage = 18.0
	projectile_speed = 370.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	for i in shot_count:
		var spread := 0.0
		if shot_count > 1:
			spread = (float(i) / float(max(shot_count - 1, 1)) - 0.5) * 0.3
		var dir := base_dir.rotated(spread)
		var proj := Node2D.new()
		proj.set_script(_PROJ)
		proj.global_position = _player.global_position
		proj.setup(dir, damage, projectile_speed,
				Color(1.0, 0.65, 0.05), Color(1.0, 0.95, 0.35))
		_get_game_root().add_child(proj)
