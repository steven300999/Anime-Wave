## Screen flash effect shown when a Limit Break ability is activated.
## Instantiate dynamically; it removes itself when the flash completes.
extends CanvasLayer

const DURATION := 0.55

var _timer := 0.0
var _flash_rect: ColorRect = null

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_flash_rect = ColorRect.new()
	_flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash_rect.color = Color(1.0, 0.85, 0.2, 1.0)
	_flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_flash_rect)

func _process(delta: float) -> void:
	_timer += delta
	var t := _timer / DURATION
	if t >= 1.0:
		queue_free()
		return
	# Ease out: fast bright flash, then quick fade
	var alpha: float
	if t < 0.15:
		alpha = t / 0.15
	else:
		alpha = 1.0 - (t - 0.15) / 0.85
	_flash_rect.color = Color(1.0, 0.85, 0.2, alpha)
