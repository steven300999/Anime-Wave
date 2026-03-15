extends Control

@onready var kill_label: Label = $CenterContainer/Panel/VBox/KillLabel
@onready var time_label: Label = $CenterContainer/Panel/VBox/TimeLabel
@onready var level_label: Label = $CenterContainer/Panel/VBox/LevelLabel

func setup(kills: int, elapsed: float, level: int) -> void:
	kill_label.text = "Enemies Defeated: %d" % kills
	var mins := int(elapsed / 60.0)
	var secs := int(elapsed) % 60
	time_label.text = "Survived: %02d:%02d" % [mins, secs]
	level_label.text = "Level Reached: %d" % level

func _ready() -> void:
	$CenterContainer/Panel/VBox/BtnRestart.pressed.connect(_on_restart)
	$CenterContainer/Panel/VBox/BtnMenu.pressed.connect(_on_menu)

func _on_restart() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
