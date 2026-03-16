## Saitama – Serious Series (One Punch Man)
## Releases a devastating shockwave around the player.
## Upgrade path: 5 levels → Limit Break → Awakened Saitama (Evolution).
extends WeaponBase

var _radius := 80.0
var _hit_cooldowns: Dictionary = {}
const HIT_CD := 0.8

var _shockwave_radius := 0.0
var _shockwave_active := false

var _aura_active := false
var _aura_timer := 0.0
const AURA_INTERVAL := 0.35

func _ready() -> void:
	super()
	weapon_name = "Serious Series"
	cooldown = 2.5
	damage = 60.0

func upgrade(level: int) -> void:
	match level:
		2: damage = 75.0;  cooldown = 2.3; _radius = 90.0
		3: damage = 90.0;  cooldown = 2.0; _radius = 100.0
		4: damage = 110.0; cooldown = 1.8; _radius = 110.0
		5: damage = 135.0; cooldown = 1.5; _radius = 125.0
		6: damage = 200.0; cooldown = 1.2; _radius = 150.0
		7: damage = 300.0; cooldown = 1.0; _radius = 200.0; _aura_active = true

func _process(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		fire(null)
		_cooldown_timer = cooldown

	if _shockwave_active:
		_shockwave_radius += 500.0 * delta
		if _shockwave_radius >= _radius + 40.0:
			_shockwave_active = false
		queue_redraw()

	if _aura_active:
		_aura_timer -= delta
		if _aura_timer <= 0.0:
			_aura_timer = AURA_INTERVAL
			_do_damage_in_radius(_radius * 0.4)
		queue_redraw()

	for key in _hit_cooldowns.keys():
		_hit_cooldowns[key] -= delta
		if _hit_cooldowns[key] <= 0.0:
			_hit_cooldowns.erase(key)

func fire(_target: Node2D) -> void:
	_shockwave_radius = 0.0
	_shockwave_active = true
	_do_damage_in_radius(_radius)

func _do_damage_in_radius(r: float) -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var enemy := e as Node2D
		if _player.global_position.distance_to(enemy.global_position) <= r:
			var id := enemy.get_instance_id()
			if not _hit_cooldowns.has(id):
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
				_hit_cooldowns[id] = HIT_CD

func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	if _shockwave_active and _shockwave_radius > 0.0:
		var alpha := clamp(1.0 - (_shockwave_radius / (_radius + 40.0)), 0.0, 1.0)
		draw_arc(Vector2.ZERO, _shockwave_radius, 0.0, TAU, 48,
				Color(1.0, 0.95, 0.2, alpha), 5.0)
		draw_arc(Vector2.ZERO, _shockwave_radius * 0.88, 0.0, TAU, 48,
				Color(1.0, 1.0, 1.0, alpha * 0.5), 2.5)
	if _aura_active:
		var pulse := (sin(t * 3.0) * 0.5 + 0.5) * 0.1
		draw_arc(Vector2.ZERO, _radius * 0.4, 0.0, TAU, 48,
				Color(1.0, 0.98, 0.4, 0.15 + pulse), 7.0)
