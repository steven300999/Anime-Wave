extends CanvasLayer

signal ability_chosen(ability_id: String)

## The three weapon paths that each have a 7-tier progression.
const WEAPON_PATHS := ["rasengan", "water_breathing", "cursed_energy"]

## Per-path data. Each "upgrades" array has exactly 7 entries (indices 0–6):
##   0 = Unlock (level 1), 1–4 = Upgrade (levels 2–5),
##   5 = Limit Break (level 6), 6 = Evolution (level 7).
const PATH_DATA := {
	"rasengan": {
		"color": Color(0.3, 0.7, 1.0),
		"upgrades": [
			{"name": "Rasengan",          "desc": "Spinning chakra orb orbits you,\ncontinuously damaging enemies.", "tier": "Unlock"},
			{"name": "Rasengan Lv.2",     "desc": "+10 damage. Intensified chakra rotation.", "tier": "Upgrade"},
			{"name": "Rasengan Lv.3",     "desc": "Orbit radius expands. Wider coverage.", "tier": "Upgrade"},
			{"name": "Rasengan Lv.4",     "desc": "+10 damage. Orbit speed increased.", "tier": "Upgrade"},
			{"name": "Rasengan Lv.5",     "desc": "+15 damage. Chakra fully charged.", "tier": "Upgrade"},
			{"name": "Rasenshuriken",     "desc": "Infuse wind chakra. Massive damage,\nlarger orbit radius.", "tier": "Limit Break"},
			{"name": "Sage Mode",         "desc": "Draw on nature energy. Three orbs,\ndouble damage, blazing orbit speed.", "tier": "Evolution"},
		],
	},
	"water_breathing": {
		"color": Color(0.2, 0.5, 1.0),
		"upgrades": [
			{"name": "Water Breathing",        "desc": "Sword slashes radiate in 8 directions\nevery 2 seconds.", "tier": "Unlock"},
			{"name": "Water Breathing Lv.2",   "desc": "+5 damage. Faster slash cadence.", "tier": "Upgrade"},
			{"name": "Water Breathing Lv.3",   "desc": "+10 damage. Blade sharpened.", "tier": "Upgrade"},
			{"name": "Water Breathing Lv.4",   "desc": "+10 damage. 12 slash directions.", "tier": "Upgrade"},
			{"name": "Water Breathing Lv.5",   "desc": "Cooldown -0.25s. Strikes reinforced.", "tier": "Upgrade"},
			{"name": "Hinokami Kagura",        "desc": "Solar breathing form. 16 directions,\ncooldown halved, +30 damage.", "tier": "Limit Break"},
			{"name": "Breath of the Sun",      "desc": "Master all 13 forms. 16 slashes,\ndouble damage, frenetic pace.", "tier": "Evolution"},
		],
	},
	"cursed_energy": {
		"color": Color(0.5, 0.0, 0.8),
		"upgrades": [
			{"name": "Cursed Energy Blast",   "desc": "Fan of cursed bolts fired toward\nnearest enemy every 1.5s.", "tier": "Unlock"},
			{"name": "Cursed Energy Lv.2",    "desc": "+1 bolt. +5 damage.", "tier": "Upgrade"},
			{"name": "Cursed Energy Lv.3",    "desc": "+5 damage. Wider spread.", "tier": "Upgrade"},
			{"name": "Cursed Energy Lv.4",    "desc": "+1 bolt. +10 damage.", "tier": "Upgrade"},
			{"name": "Cursed Energy Lv.5",    "desc": "+5 damage. +50 bolt speed.", "tier": "Upgrade"},
			{"name": "Black Flash",           "desc": "Infuse cursed energy peak. Double bolts,\ncritical damage spike.", "tier": "Limit Break"},
			{"name": "Domain Expansion",      "desc": "Unlimited Void manifested. 20 bolts in\nall directions, massive damage.", "tier": "Evolution"},
		],
	},
	"heal": {
		"color": Color(0.2, 0.8, 0.3),
		"upgrades": [{"name": "Healing Surge", "desc": "Restore 30 HP immediately.", "tier": "Pickup"}],
	},
	"speed_up": {
		"color": Color(1.0, 0.8, 0.0),
		"upgrades": [{"name": "Swift Steps", "desc": "Increase movement speed by 20%.", "tier": "Pickup"}],
	},
	"damage_up": {
		"color": Color(1.0, 0.3, 0.1),
		"upgrades": [{"name": "Power Boost", "desc": "All weapons deal 25% more damage.", "tier": "Pickup"}],
	},
}

## Text colour used for tier badges on cards.
const TIER_COLORS := {
	"Unlock":      Color(0.85, 0.85, 0.85),
	"Upgrade":     Color(0.85, 0.85, 0.85),
	"Pickup":      Color(0.85, 0.85, 0.85),
	"Limit Break": Color(1.0,  0.85, 0.0),
	"Evolution":   Color(0.9,  0.3,  1.0),
}

@onready var card_container: HBoxContainer = $Overlay/Panel/VBox/Cards
@onready var level_up_label: Label = $Overlay/Panel/VBox/TitleLabel
@onready var overlay: ColorRect = $Overlay

var _offered_ids: Array[String] = []
var _path_levels: Dictionary = {}

func _ready() -> void:
	# Must process even when the scene tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

## Show the level-up card selection screen.
## path_levels  – dict mapping each weapon path id to its current level (0 = not yet owned).
## has_any_limit_break – true if at least one path has already reached level 6.
## evolution_active    – true if an Evolution has already been chosen this run.
func show_choices(level: int, path_levels: Dictionary, has_any_limit_break: bool, evolution_active: bool) -> void:
	level_up_label.text = "Level Up! — Lv. %d\nChoose an Ability" % level
	_path_levels = path_levels.duplicate()
	_clear_cards()
	_offered_ids = _pick_abilities(3, path_levels, has_any_limit_break, evolution_active)
	for id in _offered_ids:
		_create_card(id)
	visible = true
	get_tree().paused = true

func _pick_abilities(count: int, path_levels: Dictionary, has_any_limit_break: bool, evolution_active: bool) -> Array[String]:
	var pool: Array[String] = []

	for path_id in WEAPON_PATHS:
		var current_level: int = path_levels.get(path_id, 0)
		if current_level >= 7:
			continue  # Path maxed out — no further upgrades available
		if current_level == 6:
			# Next pick would be Evolution — only offer when prerequisites are met
			if has_any_limit_break and not evolution_active:
				pool.append(path_id)
		else:
			pool.append(path_id)

	# Stat pickups are always available
	pool.append_array(["heal", "speed_up", "damage_up"])
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
	var data: Dictionary = PATH_DATA[ability_id]
	# upgrade_index == current path level (0 = not owned yet, shown as Unlock)
	var upgrade_index: int = _path_levels.get(ability_id, 0)
	var info: Dictionary = data["upgrades"][upgrade_index]
	var tier: String = info["tier"]
	var card_color: Color = data["color"]

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(220, 160)
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	btn.text = ""
	btn.add_theme_color_override("font_color", Color.WHITE)
	card_container.add_child(btn)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 4)
	btn.add_child(vbox)

	# Tier badge — only for Limit Break and Evolution
	if tier in ["Limit Break", "Evolution"]:
		var badge := Label.new()
		badge.text = "— %s! —" % tier.to_upper()
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.add_theme_color_override("font_color", TIER_COLORS[tier])
		badge.add_theme_font_size_override("font_size", 13)
		vbox.add_child(badge)

	var title := Label.new()
	title.text = info["name"]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", card_color)
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

	# Level indicator for weapon paths
	if ability_id in WEAPON_PATHS:
		var level_label := Label.new()
		level_label.text = "New!" if upgrade_index == 0 else "Lv.%d → Lv.%d" % [upgrade_index, upgrade_index + 1]
		level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_label.add_theme_color_override("font_color", TIER_COLORS[tier])
		level_label.add_theme_font_size_override("font_size", 12)
		vbox.add_child(level_label)

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
