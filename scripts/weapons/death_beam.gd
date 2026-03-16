## Death Beam — Frieza's signature high-speed piercing beam fired at the
## nearest enemy. The path of the Tyrant grows through power and cruelty,
## eventually achieving the unstoppable Black Frieza form.
extends WeaponBase

const _PROJ := preload("res://scripts/weapons/dragon_ball_projectile.gd")

var beam_count := 1

func _ready() -> void:
	super()
	weapon_name = "Death Beam"
	cooldown = 0.6
	damage = 20.0
	projectile_speed = 500.0

func fire(target: Node2D) -> void:
	var base_dir := _player.global_position.direction_to(target.global_position)
	for i in beam_count:
		var spread := 0.0
		if beam_count > 1:
			spread = (float(i) / float(max(beam_count - 1, 1)) - 0.5) * 0.2
		var dir := base_dir.rotated(spread)
		var proj := Node2D.new()
		proj.set_script(_PROJ)
		proj.global_position = _player.global_position
		proj.setup(dir, damage, projectile_speed,
				Color(0.9, 0.1, 0.9), Color(1.0, 0.6, 1.0), 6.0, true)
		_get_game_root().add_child(proj)
