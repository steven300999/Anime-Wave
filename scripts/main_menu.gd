extends Control

func _ready() -> void:
	$TitleContainer/VBox/BtnSingle.pressed.connect(_on_single)
	$TitleContainer/VBox/BtnMulti.pressed.connect(_on_multi)
	$TitleContainer/VBox/BtnQuit.pressed.connect(_on_quit)

func _on_single() -> void:
	var settings := get_node_or_null("/root/SessionSettings")
	if settings != null:
		settings.set_mode_by_id("single_pve")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_multi() -> void:
	var settings := get_node_or_null("/root/SessionSettings")
	if settings != null:
		settings.set_mode_by_id("multi_battle")
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit() -> void:
	get_tree().quit()
