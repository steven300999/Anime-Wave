## Devil Fruit Bloom — Robin sprouts arms that orbit the player, damaging enemies on contact.
## Upgrades increase arm count, orbit radius, and speed.
## Limit Break (Demonio Fleur): many fast arms. Evolution (Demon Child Awakened): giant demon form.
extends WeaponBase

const HIT_CD := 0.5

var _orbit_angle := 0.0
var _orbit_speed := 2.5   # radians per second
var _orbit_radius := 55.0
var _arm_count := 3
var _demon_form := false
var _hit_cooldowns: Dictionary = {}

func _ready() -> void:
	super()
	weapon_name = "Devil Fruit Bloom"
	cooldown = INF  # continuous — driven by orbit overlap
	damage = 20.0

func _process(delta: float) -> void:
	_orbit_angle += _orbit_speed * delta
	# Tick hit cooldowns
	for key in _hit_cooldowns.keys():
		_hit_cooldowns[key] -= delta
		if _hit_cooldowns[key] <= 0.0:
			_hit_cooldowns.erase(key)
	_check_damage()
	queue_redraw()

func _check_damage() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var enemy := e as Node2D
		var id := enemy.get_instance_id()
		if _hit_cooldowns.has(id):
			continue
		for i in _arm_count:
			var a := _orbit_angle + i * TAU / _arm_count
			var arm_pos := _player.global_position + Vector2(cos(a), sin(a)) * _orbit_radius
			if arm_pos.distance_to(enemy.global_position) < 22.0:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
				_hit_cooldowns[id] = HIT_CD
				break

func fire(_target: Node2D) -> void:
	pass  # Always active — no discrete fire event

func upgrade(level: int) -> void:
	match level:
		1:
			damage += 5.0
			_arm_count = 4
		2:
			damage += 5.0
			_orbit_speed += 0.5
			_orbit_radius += 10.0
		3:
			_arm_count = 5
			damage += 8.0
		4:
			damage += 8.0
			_orbit_speed += 0.5
			_orbit_radius += 15.0
		5:
			damage += 10.0
			_orbit_speed += 0.5
			_arm_count += 1

func activate_limit_break() -> void:
	damage *= 1.6
	_arm_count = 8
	_orbit_radius += 20.0
	_orbit_speed += 1.0

func activate_evolution() -> void:
	weapon_name = "Demon Child Awakened"
	_demon_form = true
	damage *= 2.2
	_arm_count = 12
	_orbit_radius = 100.0
	_orbit_speed = 5.0

func _draw() -> void:
	if _player == null:
		return
	for i in _arm_count:
		var a := _orbit_angle + i * TAU / _arm_count
		var offset := Vector2(cos(a), sin(a)) * _orbit_radius
		var arm_col := Color(0.3, 0.0, 0.55, 0.85) if _demon_form else Color(0.95, 0.78, 0.65, 0.85)
		var glow_col := Color(0.75, 0.0, 1.0, 0.35) if _demon_form else Color(0.95, 0.78, 0.65, 0.3)
		draw_circle(offset, 14.0, glow_col)
		draw_circle(offset, 9.0, arm_col)
		# Three finger-like extensions
		for j in 3:
			var fang_a := a + (j - 1) * 0.4
			var fang_pos := offset + Vector2(cos(fang_a), sin(fang_a)) * 12.0
			draw_circle(fang_pos, 3.5, arm_col)
