## Rasengan (Naruto) — a spinning chakra orb that orbits the player and
## damages any enemy it touches. Periodically resets its orbit angle for
## full coverage.
extends WeaponBase

const ORBIT_RADIUS := 50.0
const ORBIT_SPEED := 3.0  # radians/sec

var _orbit_angle := 0.0
var _hit_cooldowns: Dictionary = {}
var _hit_cd_time := 0.5

func _ready() -> void:
	super()
	weapon_name = "Rasengan"
	cooldown = 999.0  # continuous — handled by overlap
	damage = 25.0

func _process(delta: float) -> void:
	_orbit_angle += ORBIT_SPEED * delta
	var offset := Vector2(cos(_orbit_angle), sin(_orbit_angle)) * ORBIT_RADIUS
	global_position = _player.global_position + offset
	# Tick down hit cooldowns
	for key in _hit_cooldowns.keys():
		_hit_cooldowns[key] -= delta
		if _hit_cooldowns[key] <= 0.0:
			_hit_cooldowns.erase(key)
	# Check overlaps manually
	_check_damage()
	queue_redraw()

func _check_damage() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var enemy := e as Node2D
		if global_position.distance_to(enemy.global_position) < 28.0:
			var id := enemy.get_instance_id()
			if not _hit_cooldowns.has(id):
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
				_hit_cooldowns[id] = _hit_cd_time

func fire(_target: Node2D) -> void:
	pass  # Rasengan is always active — no discrete fire event

func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	# Outer spinning rings
	for i in 3:
		var a := t * 4.0 + i * TAU / 3.0
		var ring_pos := Vector2(cos(a), sin(a)) * 10.0
		draw_circle(ring_pos, 6.0, Color(0.2, 0.6, 1.0, 0.6))
	# Core orb
	draw_circle(Vector2.ZERO, 14.0, Color(0.5, 0.85, 1.0, 0.85))
	draw_circle(Vector2.ZERO, 8.0, Color(1.0, 1.0, 1.0, 0.9))
	# Chakra spiral lines
	for i in 6:
		var a := t * 6.0 + i * TAU / 6.0
		var p1 := Vector2(cos(a), sin(a)) * 4.0
		var p2 := Vector2(cos(a + 0.8), sin(a + 0.8)) * 13.0
		draw_line(p1, p2, Color(0.4, 0.9, 1.0, 0.7), 1.5)
