## Weather Bolt — Nami's lightning strike. Damages all enemies in range on spawn.
extends Node2D

const STRIKE_RADIUS := 38.0

var _damage := 28.0
var _lifetime := 0.45
var _elapsed := 0.0
var _awakened := false

func setup(dmg: float, awakened: bool = false) -> void:
	_damage = dmg
	_awakened = awakened

func _ready() -> void:
	call_deferred("_apply_damage")
	queue_redraw()

func _apply_damage() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if not is_instance_valid(e):
			continue
		var enemy := e as Node2D
		if global_position.distance_to(enemy.global_position) < STRIKE_RADIUS:
			if enemy.has_method("take_damage"):
				enemy.take_damage(_damage)

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _lifetime:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var t := _elapsed / _lifetime
	var alpha := 1.0 - t
	var col := Color(0.85, 0.15, 1.0, alpha * 0.9) if _awakened else Color(1.0, 0.95, 0.15, alpha * 0.9)
	var glow := Color(0.8, 0.4, 1.0, alpha * 0.35) if _awakened else Color(1.0, 1.0, 0.5, alpha * 0.4)
	# Expanding ring at strike radius
	draw_arc(Vector2.ZERO, STRIKE_RADIUS * (0.5 + t * 0.5), 0.0, TAU, 32, Color(col.r, col.g, col.b, alpha * 0.5), 2.0)
	# Outer glow
	draw_circle(Vector2.ZERO, STRIKE_RADIUS * (1.0 - t * 0.4), glow)
	# Inner flash
	draw_circle(Vector2.ZERO, 20.0 * (1.0 - t * 0.6), col)
	draw_circle(Vector2.ZERO, 8.0 * (1.0 - t * 0.7), Color(1.0, 1.0, 1.0, alpha))
	# Jagged lightning spikes
	var angle_step := TAU / 8.0
	for i in 8:
		var a := i * angle_step + t * 2.0
		var mid := Vector2(cos(a + 0.25), sin(a + 0.25)) * (STRIKE_RADIUS * 0.45)
		var outer := Vector2(cos(a), sin(a)) * (STRIKE_RADIUS * 0.85)
		draw_line(Vector2.ZERO, mid, Color(1.0, 1.0, 1.0, alpha * 0.7), 2.0)
		draw_line(mid, outer, col, 1.5)
