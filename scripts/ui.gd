extends CanvasLayer

@onready var health_bar: ProgressBar = $HUD/TopLeft/HealthBarBG/HealthBar
@onready var health_label: Label = $HUD/TopLeft/HealthBarBG/HealthLabel
@onready var exp_bar: ProgressBar = $HUD/TopLeft/ExpBarBG/ExpBar
@onready var level_label: Label = $HUD/TopLeft/LevelLabel
@onready var wave_label: Label = $HUD/TopRight/WaveLabel
@onready var kill_label: Label = $HUD/TopRight/KillLabel
@onready var timer_label: Label = $HUD/TopRight/TimerLabel

var _elapsed := 0.0

func _process(delta: float) -> void:
	_elapsed += delta
	var mins := int(_elapsed / 60.0)
	var secs := int(_elapsed) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]

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
	kill_label.text = "Kills: %d" % kills

func get_elapsed() -> float:
	return _elapsed
