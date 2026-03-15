## Scrolling infinite background that tiles a grid following the camera.
extends Node2D

const TILE_SIZE := 64
const BG_COLOR := Color(0.04, 0.03, 0.12)
const GRID_COLOR := Color(0.11, 0.11, 0.26, 0.65)
const ACCENT_COLOR := Color(0.14, 0.14, 0.35, 0.4)

var _camera: Camera2D = null
var _vp_half := Vector2(700.0, 420.0)

func _ready() -> void:
	var vp_size := get_viewport().get_visible_rect().size
	_vp_half = vp_size * 0.6

func _process(_delta: float) -> void:
	if _camera == null:
		_camera = get_tree().get_first_node_in_group("main_camera") as Camera2D
		if _camera == null:
			return
	global_position = _camera.global_position
	queue_redraw()

func _draw() -> void:
	var half := _vp_half * 1.4
	# Solid background fill
	draw_rect(Rect2(-half.x, -half.y, half.x * 2.0, half.y * 2.0), BG_COLOR)

	if _camera == null:
		return

	# Align grid lines to world-space multiples of TILE_SIZE
	var cam := _camera.global_position
	var ox := -fmod(cam.x, float(TILE_SIZE))
	var oy := -fmod(cam.y, float(TILE_SIZE))
	# Push start far enough left/top to cover the full visible area
	while ox > -half.x:
		ox -= TILE_SIZE
	while oy > -half.y:
		oy -= TILE_SIZE

	var ix := 0
	var x := ox
	while x < half.x:
		var col := ACCENT_COLOR if ix % 4 == 0 else GRID_COLOR
		draw_line(Vector2(x, -half.y), Vector2(x, half.y), col, 1.0)
		x += TILE_SIZE
		ix += 1

	var iy := 0
	var y := oy
	while y < half.y:
		var col := ACCENT_COLOR if iy % 4 == 0 else GRID_COLOR
		draw_line(Vector2(-half.x, y), Vector2(half.x, y), col, 1.0)
		y += TILE_SIZE
		iy += 1
