extends Node
class_name SessionSettings

enum GameMode {
	SINGLE_PVE,
	MULTI_BATTLE,
}

var selected_mode: GameMode = GameMode.SINGLE_PVE

func set_mode_by_id(mode_id: String) -> void:
	match mode_id:
		"single_pve":
			selected_mode = GameMode.SINGLE_PVE
		"multi_battle":
			selected_mode = GameMode.MULTI_BATTLE
		_:
			selected_mode = GameMode.SINGLE_PVE

func is_multiplayer_mode() -> bool:
	return selected_mode == GameMode.MULTI_BATTLE

func mode_name() -> String:
	return "Multiplayer LMS" if is_multiplayer_mode() else "Single PvE"
