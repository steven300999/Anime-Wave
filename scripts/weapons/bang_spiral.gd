## Bang – Water Stream Rock Smashing (One Punch Man)
## Devastating circular spiral technique dealing close-range damage.
## Upgrade path: 5 levels → Limit Break → Martial Arts Master (Evolution).
extends WeaponBase

var _sweep_angle := 0.0
var _sweep_active := false
var _sweep_timer := 0.0
const SWEEP_DURATION := 0.45

var _sweep_radius := 65.0
var _hit_cooldowns: Dictionary = {}
const HIT_CD := 0.55

var _continuous := false
var _cont_angle := 0.0

func _ready() -> void:
	super()
	weapon_name = "Water Stream Rock Smashing"
	cooldown = 1.5
	damage = 40.0

func upgrade(level: int) -> void:
	match level:
		2: damage = 52.0;  cooldown = 1.35
		3: damage = 65.0;  cooldown = 1.2;  _sweep_radius = 75.0
		4: damage = 80.0;  cooldown = 1.05; _sweep_radius = 85.0
		5: damage = 100.0; cooldown = 0.9;  _sweep_radius = 100.0
		6: damage = 160.0; cooldown = 0.72; _sweep_radius = 125.0
		7: damage = 240.0; cooldown = 0.55; _sweep_radius = 155.0; _continuous = true

func _process(delta: float) -> void:
	_cooldown_timer -= delta
	if _cooldown_timer <= 0.0:
		fire(null)
		_cooldown_timer = cooldown

	if _sweep_active:
		_sweep_timer += delta
		_sweep_angle += TAU * 2.5 * delta
		_check_sweep_damage()
		if _sweep_timer >= SWEEP_DURATION:
			_sweep_active = false
		queue_redraw()

	if _continuous:
		_cont_angle += TAU * 1.2 * delta
		_check_sweep_damage()
		queue_redraw()

	for key in _hit_cooldowns.keys():
		_hit_cooldowns[key] -= delta
		if _hit_cooldowns[key] <= 0.0:
			_hit_cooldowns.erase(key)

func fire(_target: Node2D) -> void:
	_sweep_active = true
	_sweep_timer = 0.0
	_sweep_angle = 0.0

func _check_sweep_damage() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var enemy := e as Node2D
		if _player.global_position.distance_to(enemy.global_position) <= _sweep_radius:
			var id := enemy.get_instance_id()
			if not _hit_cooldowns.has(id):
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
				_hit_cooldowns[id] = HIT_CD

func _draw() -> void:
	var angle := _sweep_angle if _sweep_active else _cont_angle
	if not (_sweep_active or _continuous):
		return
	# Spiral arms
	for arm in 5:
		var base_a := angle + arm * TAU / 5.0
		for seg in 5:
			var frac0 := float(seg) / 5.0
			var frac1 := float(seg + 1) / 5.0
			var r0 := _sweep_radius * frac0
			var r1 := _sweep_radius * frac1
			var a0 := base_a + frac0 * 1.2
			var a1 := base_a + frac1 * 1.2
			var p0 := Vector2(cos(a0), sin(a0)) * r0
			var p1 := Vector2(cos(a1), sin(a1)) * r1
			var alpha := 1.0 - (_sweep_timer / SWEEP_DURATION) if _sweep_active else 0.55
			draw_line(p0, p1, Color(0.2, 0.6, 1.0, alpha), 3.0)
	# Outer ring
	draw_arc(Vector2.ZERO, _sweep_radius, 0.0, TAU, 48, Color(0.3, 0.65, 1.0, 0.3), 1.5)
