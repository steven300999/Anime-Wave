## Weather Staff — Nami calls down lightning strikes on and near the nearest enemy.
## Upgrades increase bolt count and scatter radius.
## Limit Break: storm barrage. Evolution (Climatact Awakening): awakened purple tempest.
extends WeaponBase

const BOLT_SCENE := preload("res://scenes/weapons/weather_bolt.tscn")

var _bolt_count := 1
var _scatter_radius := 40.0
var _awakened := false

func _ready() -> void:
	super()
	weapon_name = "Weather Staff"
	cooldown = 1.8
	damage = 28.0

func fire(target: Node2D) -> void:
	for i in _bolt_count:
		var pos := target.global_position
		if i > 0:
			var angle := randf() * TAU
			var distance := randf() * _scatter_radius
			pos += Vector2(cos(angle), sin(angle)) * distance
		var bolt: Node2D = BOLT_SCENE.instantiate()
		bolt.global_position = pos
		bolt.setup(damage, _awakened)
		_get_game_root().add_child(bolt)

func upgrade(level: int) -> void:
	match level:
		1:
			damage += 8.0
			cooldown = maxf(1.4, cooldown - 0.1)
		2:
			_bolt_count = 2
			damage += 5.0
		3:
			_bolt_count = 3
			damage += 8.0
			_scatter_radius = 80.0
		4:
			_bolt_count = 4
			cooldown = maxf(1.0, cooldown - 0.1)
			damage += 6.0
		5:
			damage += 8.0
			cooldown = maxf(0.75, cooldown - 0.1)
			_bolt_count += 1

func activate_limit_break() -> void:
	damage *= 1.6
	_bolt_count = 6
	cooldown = maxf(0.65, cooldown - 0.3)
	_scatter_radius = 120.0

func activate_evolution() -> void:
	weapon_name = "Climatact Awakening"
	_awakened = true
	damage *= 2.0
	_bolt_count = 8
	cooldown = 0.5
	_scatter_radius = 200.0
