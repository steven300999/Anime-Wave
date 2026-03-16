extends CanvasLayer

signal ability_chosen(ability_id: String)

# Maximum level each ability can reach
const MAX_LEVELS := {
	"rasengan": 3,
	"water_breathing": 3,
	"cursed_energy": 3,
	"zoro": 3,
	"frieza": 4,
	"goku": 3,
	"heal": 3,
	"speed_up": 3,
	"damage_up": 3,
}

const ABILITIES := {
	"rasengan": {
		"name": "Rasengan",
		"color": Color(0.3, 0.7, 1.0),
		"descs": [
			"Orbiting chakra orb that continuously\ndamages nearby enemies.",
			"Wider orbit, stronger chakra damage.",
			"Max orbit speed — devastating chakra power!",
		]
	},
	"water_breathing": {
		"name": "Water Breathing",
		"color": Color(0.2, 0.5, 1.0),
		"descs": [
			"Sword slashes radiate in 8 directions\nevery 2 seconds.",
			"Water Wheel: faster cooldown,\nhigher damage.",
			"Constant Flux: 16-direction relentless\nslash storm!",
		]
	},
	"cursed_energy": {
		"name": "Cursed Energy Blast",
		"color": Color(0.5, 0.0, 0.8),
		"descs": [
			"5 cursed bolts fan toward\nthe nearest enemy every 1.5s.",
			"7-bolt barrage, shorter cooldown.",
			"9-bolt rapid-fire cursed assault!",
		]
	},
	"zoro": {
		"name": "Three Sword Style",
		"color": Color(0.1, 0.85, 0.2),
		"descs": [
			"Oni Giri: Slash in 3 directions\nevery 2.5 seconds.",
			"Tiger Hunt: Slash in 6 directions,\nhigher damage.",
			"Hell's Memory: 8-direction sword storm,\nmassive damage!",
		]
	},
	"frieza": {
		"name": "Frieza Death Beam",
		"color": Color(0.9, 0.2, 0.7),
		"descs": [
			"Fire a piercing Death Beam\ntoward the nearest enemy.",
			"Twin Beams: two simultaneous\ndeath beams.",
			"Death Saucer: triple beam spread,\nhigher damage.",
			"Golden Form: 5-beam barrage —\nmaximum power!",
		]
	},
	"goku": {
		"name": "Kamehameha",
		"color": Color(0.3, 0.8, 1.0),
		"descs": [
			"Kamehameha: powerful blue ki\nwave toward the enemy.",
			"Super Kamehameha: triple wave\nburst, massive damage.",
			"Limit Break: Ultra Instinct —\n5-wave barrage at full power!",
		]
	},
	"heal": {
		"name": "Healing Surge",
		"color": Color(0.2, 0.8, 0.3),
		"descs": [
			"Restore 30 HP immediately.",
			"Restore another 30 HP.",
			"Final surge — restore 30 HP!",
		]
	},
	"speed_up": {
		"name": "Swift Steps",
		"color": Color(1.0, 0.8, 0.0),
		"descs": [
			"Increase movement speed by 20%.",
			"Another +20% movement speed.",
			"Final sprint — +20% movement speed!",
		]
	},
	"damage_up": {
		"name": "Power Boost",
		"color": Color(1.0, 0.3, 0.1),
		"descs": [
			"All weapons deal 25% more damage.",
			"Another +25% damage to all weapons.",
			"Max power — +25% damage to all weapons!",
		]
	},
}

@onready var card_container: HBoxContainer = $Overlay/Panel/VBox/Cards
@onready var level_up_label: Label = $Overlay/Panel/VBox/TitleLabel
@onready var overlay: ColorRect = $Overlay

var _offered_ids: Array[String] = []

func _ready() -> void:
	# Must process even when the scene tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_choices(level: int, ability_levels: Dictionary) -> void:
	level_up_label.text = "Level Up! — Lv. %d\nChoose an Ability" % level
	_clear_cards()
	_offered_ids = _pick_abilities(3, ability_levels)
	for id in _offered_ids:
		_create_card(id, ability_levels.get(id, 0))
	visible = true
	get_tree().paused = true

func _pick_abilities(count: int, ability_levels: Dictionary) -> Array[String]:
	var pool := ABILITIES.keys().duplicate()
	# Exclude abilities that have already reached their maximum level
	pool = pool.filter(func(id: String) -> bool:
		var cur_level: int = ability_levels.get(id, 0)
		var max_level: int = MAX_LEVELS.get(id, 1)
		return cur_level < max_level)
	pool.shuffle()
	var result: Array[String] = []
	for id in pool:
		if result.size() >= count:
			break
		result.append(id)
	return result

func _clear_cards() -> void:
	for child in card_container.get_children():
		child.queue_free()

func _create_card(ability_id: String, current_level: int) -> void:
	var info: Dictionary = ABILITIES[ability_id]
	var next_level := current_level + 1
	var descs: Array = info["descs"]
	var desc: String = descs[current_level] if current_level < descs.size() else ""

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(220, 150)
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	btn.text = ""
	btn.add_theme_color_override("font_color", Color.WHITE)
	card_container.add_child(btn)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	btn.add_child(vbox)

	var title := Label.new()
	title.text = info["name"]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", info["color"])
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	var level_label := Label.new()
	var max_lv: int = MAX_LEVELS.get(ability_id, 1)
	if current_level == 0:
		level_label.text = "[ NEW ]"
		level_label.add_theme_color_override("font_color", Color(0.95, 0.8, 0.15))
	else:
		level_label.text = "Lv. %d  →  %d / %d" % [current_level, next_level, max_lv]
		level_label.add_theme_color_override("font_color", Color(0.6, 0.95, 0.6))
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(level_label)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var desc_label := Label.new()
	desc_label.text = desc
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	vbox.add_child(desc_label)

	btn.pressed.connect(_on_card_pressed.bind(ability_id))

func _on_card_pressed(ability_id: String) -> void:
	get_tree().paused = false
	visible = false
	ability_chosen.emit(ability_id)
