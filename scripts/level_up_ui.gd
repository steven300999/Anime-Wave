extends CanvasLayer

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

@onready var card_container: HBoxContainer = $Overlay/Panel/VBox/Cards
@onready var level_up_label: Label = $Overlay/Panel/VBox/TitleLabel
@onready var overlay: ColorRect = $Overlay

func _ready() -> void:
	# Must process even when the scene tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

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
	vbox.add_theme_constant_override("separation", 6)
	btn.add_child(vbox)

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
	title.add_theme_color_override("font_color",
		Color(0.4, 0.4, 0.4) if is_greyed else path_data["color"])
	title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(title)

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
