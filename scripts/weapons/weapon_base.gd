## Base class for all auto-firing weapons.
## Weapons are added as children of the Player node.
class_name WeaponBase
extends Node2D

@export var weapon_name := "Weapon"
@export var cooldown := 1.0
@export var damage := 15.0
@export var projectile_speed := 300.0

var _cooldown_timer := 0.0
var _player: Node2D = null

func _ready() -> void:
	_player = get_parent() as Node2D

func _process(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		var target := _get_target()
		if target != null:
			fire(target)
			_cooldown_timer = cooldown

func _get_target() -> Node2D:
	if _player == null:
		return null
	if _player.has_method("get_nearest_enemy"):
		return _player.get_nearest_enemy()
	return null

## Override in subclasses to implement firing logic.
func fire(_target: Node2D) -> void:
	pass

func _get_game_root() -> Node:
	return get_tree().current_scene
