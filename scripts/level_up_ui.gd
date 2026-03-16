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
signal ability_chosen(path_id: String)

## Per-path data: 7 tiers each.
## Levels 1-5 are regular upgrades, 6 = Limit Break, 7 = Evolution.
const PATHS := {
	"naruto": {
		"path_name": "Naruto Uzumaki",
		"universe": "Naruto",
		"color": Color(1.0, 0.7, 0.1),
		"levels": {
			1: {"name": "Rasengan", "desc": "A spinning chakra orb orbits you,\ncontinuously damaging nearby enemies."},
			2: {"name": "Rasengan+", "desc": "The Rasengan grows more powerful,\ndealing 30% extra damage."},
			3: {"name": "Twin Rasengan", "desc": "A second orbit of chakra joins in,\ndealing 50% extra damage."},
			4: {"name": "Rasenshuriken", "desc": "Rasengan sharpens into a shuriken form,\nhitting enemies at greater range."},
			5: {"name": "Giant Rasengan", "desc": "Rasengan triples in size and power,\ncrushing all in its path."},
			6: {"name": "Ultra Rasengan", "desc": "Chakra surges beyond its limits!\nAll Rasengan deal 3× damage."},
			7: {"name": "Nine-Tails Mode", "desc": "Tap into the Nine-Tails' power.\nSpeed and Rasengan damage both +100%."},
		}
	},
	"tanjiro": {
		"path_name": "Tanjiro Kamado",
		"universe": "Demon Slayer",
		"color": Color(0.2, 0.5, 1.0),
		"levels": {
			1: {"name": "Water Breathing", "desc": "Sword slashes radiate in 8 directions\nevery 2 seconds."},
			2: {"name": "Second Form: Water Wheel", "desc": "Spinning slash hits all\nsurrounding enemies. +30% dmg."},
			3: {"name": "Third Form: Flowing Dance", "desc": "Slash interval reduced to 1.3 s.\nDamage increased by 30%."},
			4: {"name": "Sixth Form: Whirlpool", "desc": "Water tornadoes pull in enemies\nand deal heavy burst damage."},
			5: {"name": "Tenth Form: Constant Flux", "desc": "Slash count and damage continuously\namplified. +30% dmg."},
			6: {"name": "Hinokami Kagura", "desc": "Master the Sun Breathing technique!\nAll slashes deal 3× damage."},
			7: {"name": "Demon Slayer Mark", "desc": "The Mark awakens — slash speed\nand range are both doubled."},
		}
	},
	"itadori": {
		"path_name": "Itadori Yuji",
		"universe": "Jujutsu Kaisen",
		"color": Color(0.8, 0.1, 0.9),
		"levels": {
			1: {"name": "Cursed Energy Blast", "desc": "Fan of cursed bolts fired toward\nnearest enemy every 1.5 s."},
			2: {"name": "Divergent Fist", "desc": "Blasts resonate with cursed energy,\ndealing 30% more damage."},
			3: {"name": "Soul Multiplicity", "desc": "Bolts pierce through enemies,\nhitting all those behind them."},
			4: {"name": "Body Repel", "desc": "Cursed blasts knock foes back far\nand leave them disoriented."},
			5: {"name": "1000 Strikes", "desc": "Bolt count and fire rate massively\nincreased. +30% dmg, faster cooldown."},
			6: {"name": "Black Flash", "desc": "Cursed energy overflows!\nAll blasts deal 3× damage."},
			7: {"name": "Sukuna's Domain", "desc": "The King of Curses takes over.\nAll damage +100%, faster fire rate."},
		}
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
## Show 3 ability cards (up to 1 per path). Pauses the game.
## path_levels maps path_id -> current level (0 / absent = unowned).
## has_evolution is true when the player already has an Evolution active.
func show_choices(level: int, path_levels: Dictionary, has_evolution: bool) -> void:
	level_up_label.text = "Level Up! — Lv. %d\nChoose a Path Upgrade" % level
	_clear_cards()
	var offered := _pick_upgrades(path_levels)
	for entry in offered:
		_create_card(entry["path_id"], entry["next_level"], has_evolution)
	visible = true
	get_tree().paused = true

## Returns up to 3 entries {path_id, next_level} in random order.
func _pick_upgrades(path_levels: Dictionary) -> Array:
	var pool: Array = []
	for path_id in PATHS.keys():
		var current: int = path_levels.get(path_id, 0)
		if current < 7:
			pool.append({"path_id": path_id, "next_level": current + 1})
	pool.shuffle()
	var result: Array = []
	for entry in pool:
		if result.size() >= 3:
			break
		result.append(entry)
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
func _create_card(path_id: String, next_level: int, has_evolution: bool) -> void:
	var path_data: Dictionary = PATHS[path_id]
	var level_data: Dictionary = path_data["levels"][next_level]
	var is_limit_break := next_level == 6
	var is_evolution   := next_level == 7
	var is_greyed      := is_evolution and has_evolution

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(240, 220)
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	btn.text = ""
	btn.disabled = is_greyed
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

	# --- Tier badge ---
	var badge := Label.new()
	if is_evolution:
		badge.text = "★ EVOLUTION"
		badge.add_theme_color_override("font_color",
			Color(0.4, 0.4, 0.4) if is_greyed else Color(1.0, 0.5, 0.0))
	elif is_limit_break:
		badge.text = "⚡ LIMIT BREAK"
		badge.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	else:
		badge.text = "Lv. %d" % next_level
		badge.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 13)
	vbox.add_child(badge)

	# --- Ability name ---
	var title := Label.new()
	title.text = level_data["name"]
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", card_color)
	title.add_theme_color_override("font_color",
		Color(0.4, 0.4, 0.4) if is_greyed else path_data["color"])
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

	# --- Anime universe ---
	var universe_label := Label.new()
	universe_label.text = path_data["universe"]
	universe_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	universe_label.add_theme_color_override("font_color",
		Color(0.4, 0.4, 0.4) if is_greyed else Color(0.6, 0.8, 1.0))
	universe_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(universe_label)

	# --- Character path ---
	var path_label := Label.new()
	path_label.text = path_data["path_name"] + " Path"
	path_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	path_label.add_theme_color_override("font_color",
		Color(0.4, 0.4, 0.4) if is_greyed else Color(0.85, 0.75, 0.5))
	path_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(path_label)

	var sep2 := HSeparator.new()
	vbox.add_child(sep2)

	# --- Description ---
	var desc := Label.new()
	desc.text = level_data["desc"]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_color_override("font_color",
		Color(0.4, 0.4, 0.4) if is_greyed else Color(0.85, 0.85, 0.85))
	vbox.add_child(desc)

	if not is_greyed:
		btn.pressed.connect(_on_card_pressed.bind(path_id))

func _on_card_pressed(path_id: String) -> void:
	get_tree().paused = false
	visible = false
	ability_chosen.emit(path_id)
