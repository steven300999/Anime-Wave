## Tatsumaki – Psychic Lift (One Punch Man)
## Creates an orbiting psychic debris field that crushes nearby enemies.
## Upgrade path: 5 levels → Limit Break → Terrible Tornado Awakened (Evolution).
extends WeaponBase

var _orbit_angle := 0.0
var _hit_cooldowns: Dictionary = {}
const HIT_CD := 0.8

var _field_radius := 90.0
var _debris_count := 3

var _burst_active := false
var _burst_timer := 0.0
const BURST_DURATION := 0.4

var _aura_active := false
var _aura_timer := 0.0
const AURA_INTERVAL := 0.3

func _ready() -> void:
	super()
	weapon_name = "Psychic Lift"
	cooldown = 1.8
	damage = 25.0

func upgrade(level: int) -> void:
	match level:
		2: damage = 32.0;  cooldown = 1.6
		3: damage = 40.0;  cooldown = 1.4; _debris_count = 4
		4: damage = 50.0;  cooldown = 1.2; _field_radius = 105.0
		5: damage = 62.0;  cooldown = 1.0; _debris_count = 5
		6: damage = 100.0; cooldown = 0.8; _field_radius = 130.0; _debris_count = 6
		7: damage = 150.0; cooldown = 0.6; _field_radius = 160.0; _debris_count = 8; _aura_active = true

func _process(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		fire(null)
		_cooldown_timer = cooldown

	_orbit_angle += 1.8 * delta

	if _burst_active:
		_burst_timer += delta
		if _burst_timer >= BURST_DURATION:
			_burst_active = false

	if _aura_active:
		_aura_timer -= delta
		if _aura_timer <= 0.0:
			_aura_timer = AURA_INTERVAL
			_do_damage_in_radius(_field_radius * 0.35)

	for key in _hit_cooldowns.keys():
		_hit_cooldowns[key] -= delta
		if _hit_cooldowns[key] <= 0.0:
			_hit_cooldowns.erase(key)

	queue_redraw()

func fire(_target: Node2D) -> void:
	_burst_active = true
	_burst_timer = 0.0
	_do_damage_in_radius(_field_radius)

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
	# Orbiting debris pieces
	for i in _debris_count:
		var angle := _orbit_angle + i * TAU / float(_debris_count)
		var pos := Vector2(cos(angle), sin(angle)) * _field_radius
		draw_circle(pos, 8.0, Color(0.5, 0.9, 0.3, 0.7))
		draw_circle(pos, 5.0, Color(0.75, 1.0, 0.45, 0.9))
	# Psychic field ring
	var ring_alpha := (sin(t * 3.5) * 0.5 + 0.5) * 0.3 + 0.1
	draw_arc(Vector2.ZERO, _field_radius, 0.0, TAU, 64,
			Color(0.4, 1.0, 0.2, ring_alpha), 2.5)
	# Burst flash
	if _burst_active:
		var burst_alpha := 1.0 - (_burst_timer / BURST_DURATION)
		draw_arc(Vector2.ZERO, _field_radius * 0.8, 0.0, TAU, 48,
				Color(0.6, 1.0, 0.3, burst_alpha * 0.6), 5.0)
	# Awakened aura ring
	if _aura_active:
		draw_arc(Vector2.ZERO, _field_radius * 0.35, 0.0, TAU, 32,
				Color(0.5, 1.0, 0.2, 0.25), 4.0)
