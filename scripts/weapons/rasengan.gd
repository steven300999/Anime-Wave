## Rasengan (Naruto) — a spinning chakra orb that orbits the player and
## damages any enemy it touches.
## Supports 7-tier progression: levels 2-5 are stat upgrades, level 6 is the
## Rasenshuriken Limit Break, and level 7 is the Sage Mode Evolution (3 orbs).
extends WeaponBase

var _orbit_radius := 50.0
var _orbit_speed_val := 3.0  # radians/sec
var _orbit_count := 1        # number of simultaneous orbiting orbs

var _orbit_angle := 0.0
var _hit_cooldowns: Dictionary = {}
var _hit_cd_time := 0.5

func _ready() -> void:
	super()
	weapon_name = "Rasengan"
	cooldown = 999.0  # continuous — handled by overlap
	damage = 25.0

func _process(delta: float) -> void:
	_orbit_angle += _orbit_speed_val * delta
	# Node stays at player position; orbs are drawn/checked as offsets
	global_position = _player.global_position
	# Tick down hit cooldowns
	for key in _hit_cooldowns.keys():
		_hit_cooldowns[key] -= delta
		if _hit_cooldowns[key] <= 0.0:
			_hit_cooldowns.erase(key)
	# Check overlaps for all active orbs
	_check_damage()
	queue_redraw()

## Returns the world-space offset of each active orbiting orb.
func _get_orb_offsets() -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	for i in _orbit_count:
		var angle := _orbit_angle + i * TAU / _orbit_count
		offsets.append(Vector2(cos(angle), sin(angle)) * _orbit_radius)
	return offsets

func _check_damage() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for orb_offset in _get_orb_offsets():
		var orb_global := global_position + orb_offset
		for e in enemies:
			if not is_instance_valid(e):
				continue
			var enemy := e as Node2D
			if orb_global.distance_to(enemy.global_position) < 28.0:
				var id := enemy.get_instance_id()
				if not _hit_cooldowns.has(id):
					if enemy.has_method("take_damage"):
						enemy.take_damage(damage)
					_hit_cooldowns[id] = _hit_cd_time

func fire(_target: Node2D) -> void:
	pass  # Rasengan is always active — no discrete fire event

## Apply the stat changes for the given path level (2–7).
func upgrade(level: int) -> void:
	match level:
		2: damage += 10.0
		3: _orbit_radius += 10.0
		4:
			damage += 10.0
			_orbit_speed_val *= 1.3
		5: damage += 15.0
		6:  # Limit Break — Rasenshuriken
			damage += 30.0
			_orbit_radius += 20.0
			_orbit_speed_val *= 1.5
		7:  # Evolution — Sage Mode
			_orbit_count = 3
			damage *= 2.0
			_orbit_speed_val *= 1.5

func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for i in _orbit_count:
		var orb_offset := _get_orb_offsets()[i]
		# Outer spinning rings
		for j in 3:
			var a := t * 4.0 + j * TAU / 3.0
			var ring_pos := orb_offset + Vector2(cos(a), sin(a)) * 10.0
			draw_circle(ring_pos, 6.0, Color(0.2, 0.6, 1.0, 0.6))
		# Core orb
		draw_circle(orb_offset, 14.0, Color(0.5, 0.85, 1.0, 0.85))
		draw_circle(orb_offset, 8.0, Color(1.0, 1.0, 1.0, 0.9))
		# Chakra spiral lines
		for j in 6:
			var a := t * 6.0 + j * TAU / 6.0
			var p1 := orb_offset + Vector2(cos(a), sin(a)) * 4.0
			var p2 := orb_offset + Vector2(cos(a + 0.8), sin(a + 0.8)) * 13.0
			draw_line(p1, p2, Color(0.4, 0.9, 1.0, 0.7), 1.5)
