## Pride Strike — Vegeta fires a proud volley of energy bolts toward the
## nearest enemy. The path of Pride rises through rivalry and the drive to
## surpass all limits, culminating in Super Saiyan Blue Evolved.
extends WeaponBase

const _PROJ := preload("res://scripts/weapons/dragon_ball_projectile.gd")

var shot_count := 3

func _ready() -> void:
	super()
	weapon_name = "Pride Strike"
	cooldown = 1.0
	damage = 22.0
	projectile_speed = 350.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	for i in shot_count:
		var spread := 0.0
		if shot_count > 1:
			spread = (float(i) / float(max(shot_count - 1, 1)) - 0.5) * 0.35
		var dir := base_dir.rotated(spread)
		var proj := Node2D.new()
		proj.set_script(_PROJ)
		proj.global_position = _player.global_position
		proj.setup(dir, damage, projectile_speed,
				Color(0.5, 0.3, 1.0), Color(0.8, 0.6, 1.0))
		_get_game_root().add_child(proj)
