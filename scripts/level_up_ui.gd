extends CanvasLayer

signal ability_chosen(ability_id: String)

const ONCE_ONLY := ["rasengan", "water_breathing", "cursed_energy", "limit_break", "evolution"]

## Minimum player level required before this ability can appear in the pool.
const ABILITY_MIN_LEVEL := {
	"limit_break": 6,
	"evolution": 8,
}

const ABILITIES := {
	"rasengan": {
		"name": "Rasengan",
		"desc": "Spinning chakra orb that orbits you,\ncontinuously damaging enemies.",
		"color": Color(0.3, 0.7, 1.0)
	},
	"water_breathing": {
		"name": "Water Breathing",
		"desc": "Sword slashes radiate in 8 directions\nevery 2 seconds.",
		"color": Color(0.2, 0.5, 1.0)
	},
	"cursed_energy": {
		"name": "Cursed Energy Blast",
		"desc": "Fan of cursed bolts fired toward\nnearest enemy every 1.5s.",
		"color": Color(0.5, 0.0, 0.8)
	},
	"heal": {
		"name": "Healing Surge",
		"desc": "Restore 30 HP immediately.",
		"color": Color(0.2, 0.8, 0.3)
	},
	"speed_up": {
		"name": "Swift Steps",
		"desc": "Increase movement speed by 20%.",
		"color": Color(1.0, 0.8, 0.0)
	},
	"damage_up": {
		"name": "Power Boost",
		"desc": "All weapons deal 25% more damage.",
		"color": Color(1.0, 0.3, 0.1)
	},
	"limit_break": {
		"name": "⚡ LIMIT BREAK",
		"desc": "Break your limits! All weapons deal\ndouble damage and fire faster.",
		"color": Color(1.0, 0.6, 0.0)
	},
	"evolution": {
		"name": "✦ EVOLUTION",
		"desc": "Transcend your form! Maximum power —\ndamage ×3, speed ×1.5, full heal.",
		"color": Color(1.0, 0.9, 0.1)
	},
}

@onready var card_container: HBoxContainer = $Overlay/Panel/VBox/Cards
@onready var level_up_label: Label = $Overlay/Panel/VBox/TitleLabel
@onready var overlay: ColorRect = $Overlay

var _offered_ids: Array[String] = []

func _ready() -> void:
	# Must process even when the scene tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_choices(level: int, already_owned: Array) -> void:
	level_up_label.text = "Level Up! — Lv. %d\nChoose an Ability" % level
	_clear_cards()
	_offered_ids = _pick_abilities(3, already_owned, level)
	for id in _offered_ids:
		_create_card(id)
	visible = true
	get_tree().paused = true

func _pick_abilities(count: int, owned: Array, level: int) -> Array[String]:
	var pool := ABILITIES.keys().duplicate()
	# Exclude weapons/specials the player already has
	pool = pool.filter(func(id: String) -> bool:
		if id in ONCE_ONLY and id in owned:
			return false
		# Exclude special abilities not yet reachable at this level
		if ABILITY_MIN_LEVEL.has(id) and level < ABILITY_MIN_LEVEL[id]:
			return false
		return true)
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

func _create_card(ability_id: String) -> void:
	var info: Dictionary = ABILITIES[ability_id]
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(220, 140)
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

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var desc := Label.new()
	desc.text = info["desc"]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	vbox.add_child(desc)

	btn.pressed.connect(_on_card_pressed.bind(ability_id))

func _on_card_pressed(ability_id: String) -> void:
	get_tree().paused = false
	visible = false
	ability_chosen.emit(ability_id)
