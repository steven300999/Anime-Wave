extends Node2D

signal zone_updated(radius: float, progress: float)

var center := Vector2.ZERO
var start_radius := 1100.0
var end_radius := 220.0
var shrink_time := 150.0
var zone_damage := 12.0
var tick_interval := 0.5

var _elapsed := 0.0
var _tick := 0.0
var _radius := 1100.0

func configure(config: Dictionary) -> void:
	start_radius = config.get("arena_start_radius", start_radius)
	end_radius = config.get("arena_end_radius", end_radius)
	shrink_time = config.get("zone_shrink_time", shrink_time)
	zone_damage = config.get("zone_tick_damage", zone_damage)
	tick_interval = config.get("zone_tick_interval", tick_interval)
	_radius = start_radius

func _process(delta: float) -> void:
	_elapsed = min(shrink_time, _elapsed + delta)
	_tick -= delta
	var t := 0.0 if shrink_time <= 0.0 else _elapsed / shrink_time
	_radius = lerp(start_radius, end_radius, t)
	if _tick <= 0.0:
		_tick = tick_interval
		_apply_zone_damage()
	zone_updated.emit(_radius, t)
	queue_redraw()

func _apply_zone_damage() -> void:
	for node in get_tree().get_nodes_in_group("combatants"):
		if not is_instance_valid(node):
			continue
		var body := node as Node2D
		if body.global_position.distance_to(center) > _radius and body.has_method("take_damage"):
			body.take_damage(zone_damage)

func get_radius() -> float:
	return _radius

func _draw() -> void:
	draw_circle(center - global_position, _radius, Color(0.9, 0.1, 0.2, 0.08))
	draw_arc(center - global_position, _radius, 0.0, TAU, 128, Color(1.0, 0.35, 0.35, 0.7), 3.0)
