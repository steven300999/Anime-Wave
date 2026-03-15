## Basic auto-firing shot — fires a fast projectile toward the nearest enemy.
extends WeaponBase

const PROJECTILE_SCENE := preload("res://scenes/weapons/basic_shot.tscn")

func _ready() -> void:
	super()
	weapon_name = "Basic Shot"
	cooldown = 0.8
	damage = 12.0
	projectile_speed = 380.0

func fire(target: Node2D) -> void:
	var dir := (_player.global_position.direction_to(target.global_position))
	var proj: Node2D = PROJECTILE_SCENE.instantiate()
	proj.global_position = _player.global_position
	proj.setup(dir, damage, projectile_speed)
	_get_game_root().add_child(proj)
