extends Control

func _ready() -> void:
	$TitleContainer/VBox/BtnPlay.pressed.connect(_on_play)
	$TitleContainer/VBox/BtnQuit.pressed.connect(_on_quit)

func _on_play() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit() -> void:
	get_tree().quit()
