## Black Leg Kick — Sanji's powerful kick blast projectile.
extends Area2D

var _direction := Vector2.RIGHT
var _speed := 420.0
var _damage := 22.0
var _lifetime := 1.0
var _elapsed := 0.0
var _flaming := false

func setup(direction: Vector2, dmg: float, spd: float, flaming: bool = false) -> void:
	_direction = direction.normalized()
	_damage = dmg
	_speed = spd
	_flaming = flaming
	rotation = _direction.angle()

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _lifetime:
		queue_free()
		return
	global_position += _direction * _speed * delta
	queue_redraw()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(_damage)
		queue_free()

func _draw() -> void:
	var alpha := 1.0 - (_elapsed / _lifetime) * 0.6
	var col := Color(1.0, 0.45, 0.0, alpha) if _flaming else Color(0.1, 0.1, 0.25, alpha)
	var glow := Color(1.0, 0.75, 0.0, alpha * 0.5) if _flaming else Color(0.3, 0.3, 0.6, alpha * 0.4)
	# Boot-kick impact circle
	draw_circle(Vector2.ZERO, 10.0, glow)
	draw_circle(Vector2.ZERO, 6.0, col)
	# Flame or motion trail
	if _flaming:
		for i in 5:
			var t := float(i) / 4.0
			var trail_pos := Vector2(-(8.0 + t * 16.0), 0.0)
			draw_circle(trail_pos, 3.5 - t * 1.2, Color(1.0, 0.6 - t * 0.3, 0.0, alpha * (0.5 - t * 0.28)))
	else:
		draw_line(Vector2.ZERO, Vector2(-18.0, 0.0), Color(0.2, 0.2, 0.45, alpha * 0.35), 4.0)
