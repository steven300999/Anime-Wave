extends CanvasLayer

@onready var mode_label: Label = $HUD/TopLeft/ModeLabel
@onready var health_bar: ProgressBar = $HUD/TopLeft/HealthBarBG/HealthBar
@onready var health_label: Label = $HUD/TopLeft/HealthBarBG/HealthLabel
@onready var exp_bar: ProgressBar = $HUD/TopLeft/ExpBarBG/ExpBar
@onready var level_label: Label = $HUD/TopLeft/LevelLabel
@onready var wave_label: Label = $HUD/TopRight/WaveLabel
@onready var kill_label: Label = $HUD/TopRight/KillLabel
@onready var timer_label: Label = $HUD/TopRight/TimerLabel
@onready var remaining_label: Label = $HUD/TopRight/RemainingLabel
@onready var zone_label: Label = $HUD/TopRight/ZoneLabel

var _elapsed := 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	var mins := int(_elapsed / 60.0)
	var secs := int(_elapsed) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]

func set_mode(mode_text: String, is_multiplayer: bool) -> void:
	mode_label.text = mode_text
	remaining_label.visible = is_multiplayer
	zone_label.visible = is_multiplayer
	wave_label.visible = not is_multiplayer

func update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "%d / %d" % [int(current), int(maximum)]

func update_exp(current: int, required: int) -> void:
	exp_bar.max_value = required
	exp_bar.value = current

func update_level(level: int) -> void:
	level_label.text = "Lv. %d" % level

func update_wave(wave: int) -> void:
	wave_label.text = "Wave %d" % wave

func update_kills(kills: int) -> void:
	kill_label.text = "Elims: %d" % kills

func update_remaining_players(count: int) -> void:
	remaining_label.text = "Remaining: %d" % count

func update_zone_status(radius: float, progress: float) -> void:
	zone_label.text = "Zone %.0f • %d%%" % [radius, int(progress * 100.0)]

func get_elapsed() -> float:
	return _elapsed
