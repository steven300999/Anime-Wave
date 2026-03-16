## Namekian Arm — Piccolo's stretching arm orbits the player, continuously
## striking nearby enemies with heavy Namekian strength. The path of the
## Namekian grows as additional arms join the orbit, culminating in the
## Potential Unlocked Namekian form.
extends WeaponBase

const ORBIT_RADIUS := 60.0
const ORBIT_SPEED := 2.5

var arm_count := 1

var _orbit_angle := 0.0
var _arm_positions: Array[Vector2] = []
var _hit_cooldowns: Dictionary = {}
var _hit_cd_time := 0.4

func _ready() -> void:
	super()
	weapon_name = "Namekian Arm"
	cooldown = 999.0  # Continuous — handled by overlap detection
	damage = 24.0

func _process(delta: float) -> void:
	_orbit_angle += ORBIT_SPEED * delta
	_arm_positions.clear()
	for i in arm_count:
		var angle_offset := i * TAU / arm_count
		var arm_pos := _player.global_position + Vector2(
			cos(_orbit_angle + angle_offset),
			sin(_orbit_angle + angle_offset)) * ORBIT_RADIUS
		_arm_positions.append(arm_pos)
	# Tick down per-enemy hit cooldowns
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
		for arm_pos in _arm_positions:
			if arm_pos.distance_to(enemy.global_position) < 30.0:
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage)
				_hit_cooldowns[id] = _hit_cd_time
				break

func fire(_target: Node2D) -> void:
	pass  # Continuous weapon — no discrete fire event

func _draw() -> void:
	var t := Time.get_ticks_msec() / 1000.0
	for arm_pos in _arm_positions:
		var local_pos := arm_pos - _player.global_position
		# Stretching arm line
		draw_line(Vector2.ZERO, local_pos, Color(0.1, 0.7, 0.2, 0.6), 5.0)
		# Fist
		draw_circle(local_pos, 12.0, Color(0.15, 0.65, 0.15, 0.85))
		draw_circle(local_pos, 7.0, Color(0.2, 0.8, 0.2))
		# Knuckle detail
		for k in 3:
			var a := t * 3.0 + k * 0.7
			var kp := local_pos + Vector2(cos(a), sin(a)) * 5.0
			draw_circle(kp, 2.0, Color(0.1, 0.5, 0.1))
