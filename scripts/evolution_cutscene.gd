## Full-screen transformation cutscene shown when Evolution is activated.
## Lasts exactly 2 seconds, then unpauses the game and removes itself.
extends CanvasLayer

const DURATION := 2.0

var _timer := 0.0
var _bg: ColorRect = null
var _draw_node: Control = null

func _ready() -> void:
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	# Full-screen dark background
	_bg = ColorRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_bg.color = Color(0.0, 0.0, 0.0, 0.0)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bg)

	# Node used for procedural 2D drawing (runs in world space via SubViewport
	# substitute — we draw on a Control instead so it works with CanvasLayer).
	var ctrl := Control.new()
	ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ctrl.draw.connect(_on_ctrl_draw.bind(ctrl))
	add_child(ctrl)
	_draw_node = ctrl

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= DURATION:
		get_tree().paused = false
		queue_free()
		return
	_bg.color = Color(0.0, 0.0, 0.0, _bg_alpha())
	(_draw_node as Control).queue_redraw()

func _bg_alpha() -> float:
	var t := _timer / DURATION
	# Fade in dark bg quickly, hold, then fade out at the end
	if t < 0.15:
		return t / 0.15
	elif t > 0.85:
		return 1.0 - (t - 0.85) / 0.15
	return 1.0

func _on_ctrl_draw(ctrl: Control) -> void:
	var t := _timer / DURATION
	var size := ctrl.get_rect().size
	var center := size * 0.5

	# --- Phase 0: 0.0 – 0.2  initial white shockwave flash ---
	if t < 0.2:
		var p := t / 0.2
		var flash_alpha := sin(p * PI)
		ctrl.draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 1.0, 1.0, flash_alpha * 0.9))

	# --- Phase 1: 0.1 – 1.5  energy rings expanding from center ---
	var ring_phase := clamp((t - 0.1) / 1.4, 0.0, 1.0)
	if ring_phase > 0.0:
		for i in 5:
			var offset := float(i) / 5.0
			var ring_t := fmod(ring_phase + offset, 1.0)
			var radius := ring_t * 420.0
			var ring_alpha := (1.0 - ring_t) * 0.7
			# Outer ring — golden
			ctrl.draw_arc(center, radius, 0.0, TAU, 64, Color(1.0, 0.8, 0.1, ring_alpha), 3.0)
			# Inner ring — white
			ctrl.draw_arc(center, radius * 0.6, 0.0, TAU, 48, Color(1.0, 1.0, 1.0, ring_alpha * 0.5), 1.5)

	# --- Phase 1b: radiant burst lines ---
	if ring_phase > 0.0:
		var burst_alpha := sin(ring_phase * PI) * 0.6
		for i in 16:
			var angle := i * TAU / 16.0
			var length := 250.0 * ring_phase
			var end_pt := center + Vector2(cos(angle), sin(angle)) * length
			ctrl.draw_line(center, end_pt, Color(1.0, 0.9, 0.3, burst_alpha), 2.0)

	# --- Phase 2: 0.3 – 1.8  text label ---
	if t >= 0.3 and t <= 1.8:
		var text_alpha := clamp((t - 0.3) / 0.2, 0.0, 1.0) * clamp((1.8 - t) / 0.2, 0.0, 1.0)
		# Draw background pill for text
		var pill_w := 380.0
		var pill_h := 56.0
		var pill_rect := Rect2(center.x - pill_w * 0.5, center.y - pill_h * 0.5 - 20.0, pill_w, pill_h)
		ctrl.draw_rect(pill_rect, Color(0.0, 0.0, 0.0, text_alpha * 0.6))
		# Title (Godot built-in font — draw_string)
		var font := ThemeDB.fallback_font
		var fs := 36
		var msg := "EVOLUTION ACTIVATED"
		var tw := font.get_string_size(msg, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		ctrl.draw_string(font, Vector2(center.x - tw * 0.5, center.y - 5.0),
				msg, HORIZONTAL_ALIGNMENT_LEFT, -1, fs,
				Color(1.0, 0.85, 0.1, text_alpha))
		var sub := "Maximum power unlocked!"
		var sw := font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		ctrl.draw_string(font, Vector2(center.x - sw * 0.5, center.y + 24.0),
				sub, HORIZONTAL_ALIGNMENT_LEFT, -1, 18,
				Color(1.0, 1.0, 1.0, text_alpha * 0.85))

	# --- Phase 3: 1.7 – 2.0  final golden flash ---
	if t >= 1.7:
		var p := (t - 1.7) / 0.3
		var flash_alpha := sin(p * PI) * 0.5
		ctrl.draw_rect(Rect2(Vector2.ZERO, size), Color(1.0, 0.75, 0.0, flash_alpha))
