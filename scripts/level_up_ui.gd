extends CanvasLayer

signal ability_chosen(ability_id: String)

const ONCE_ONLY := [
	"rasengan", "water_breathing", "cursed_energy",
	# Dragon Ball — Goku (Ki)
	"ki_blast", "ki_1", "ki_2", "ki_3", "ki_4", "ki_5",
	"ki_limit_break", "ultra_instinct",
	# Dragon Ball — Vegeta (Pride)
	"pride_strike", "pride_1", "pride_2", "pride_3", "pride_4", "pride_5",
	"pride_limit_break", "ssb_evolved",
	# Dragon Ball — Gohan (Potential)
	"gohan_masenko", "gohan_1", "gohan_2", "gohan_3", "gohan_4", "gohan_5",
	"gohan_limit_break", "gohan_beast",
	# Dragon Ball — Piccolo (Namekian)
	"namekian_arm", "namekian_1", "namekian_2", "namekian_3", "namekian_4", "namekian_5",
	"namekian_limit_break", "unlocked_namekian",
	# Dragon Ball — Frieza (Tyrant)
	"death_beam", "tyrant_1", "tyrant_2", "tyrant_3", "tyrant_4", "tyrant_5",
	"tyrant_limit_break", "black_frieza",
]

## Maps each Dragon Ball upgrade/evolution to the ability that must already
## be owned before this ability can be offered.
const PREREQUISITES := {
	# Goku (Ki)
	"ki_1": "ki_blast", "ki_2": "ki_1", "ki_3": "ki_2",
	"ki_4": "ki_3", "ki_5": "ki_4",
	"ki_limit_break": "ki_5", "ultra_instinct": "ki_limit_break",
	# Vegeta (Pride)
	"pride_1": "pride_strike", "pride_2": "pride_1", "pride_3": "pride_2",
	"pride_4": "pride_3", "pride_5": "pride_4",
	"pride_limit_break": "pride_5", "ssb_evolved": "pride_limit_break",
	# Gohan (Potential)
	"gohan_1": "gohan_masenko", "gohan_2": "gohan_1", "gohan_3": "gohan_2",
	"gohan_4": "gohan_3", "gohan_5": "gohan_4",
	"gohan_limit_break": "gohan_5", "gohan_beast": "gohan_limit_break",
	# Piccolo (Namekian)
	"namekian_1": "namekian_arm", "namekian_2": "namekian_1", "namekian_3": "namekian_2",
	"namekian_4": "namekian_3", "namekian_5": "namekian_4",
	"namekian_limit_break": "namekian_5", "unlocked_namekian": "namekian_limit_break",
	# Frieza (Tyrant)
	"tyrant_1": "death_beam", "tyrant_2": "tyrant_1", "tyrant_3": "tyrant_2",
	"tyrant_4": "tyrant_3", "tyrant_5": "tyrant_4",
	"tyrant_limit_break": "tyrant_5", "black_frieza": "tyrant_limit_break",
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
	# ── Dragon Ball: Goku — Ki Path ──────────────────────────────────────────
	"ki_blast": {
		"name": "Ki Blast",
		"desc": "Goku fires rapid ki shots toward\nthe nearest enemy. [Ki Path]",
		"color": Color(1.0, 0.6, 0.1)
	},
	"ki_1": {
		"name": "Ki Mastery I",
		"desc": "Ki Blast fires faster & harder.\n+20% damage, 15% faster fire rate.",
		"color": Color(1.0, 0.75, 0.1)
	},
	"ki_2": {
		"name": "Ki Mastery II",
		"desc": "Ki Blast fires a double burst.\n+25% damage, 2 shots per volley.",
		"color": Color(1.0, 0.85, 0.15)
	},
	"ki_3": {
		"name": "Super Saiyan Aura",
		"desc": "Golden power surges through you!\n+50% damage to Ki Blast.",
		"color": Color(1.0, 0.9, 0.2)
	},
	"ki_4": {
		"name": "Super Saiyan 2",
		"desc": "Electricity crackles — power doubles!\n+50% damage to Ki Blast.",
		"color": Color(1.0, 0.95, 0.3)
	},
	"ki_5": {
		"name": "Super Saiyan Blue",
		"desc": "Divine Ki mastery achieved!\n+80% damage, 3 shots per volley.",
		"color": Color(0.2, 0.6, 1.0)
	},
	"ki_limit_break": {
		"name": "Kamehameha!",
		"desc": "KAAAAMEEE HAAAAMEEE HAAA!\n×2 damage, 30% faster fire rate.",
		"color": Color(0.4, 0.8, 1.0)
	},
	"ultra_instinct": {
		"name": "Ultra Instinct",
		"desc": "The pinnacle of martial arts.\n×3 damage, blazing silver Ki Blasts.",
		"color": Color(0.85, 0.9, 1.0)
	},
	# ── Dragon Ball: Vegeta — Pride Path ─────────────────────────────────────
	"pride_strike": {
		"name": "Pride Strike",
		"desc": "Vegeta fires a proud volley of\n3 energy bolts. [Pride Path]",
		"color": Color(0.5, 0.3, 1.0)
	},
	"pride_1": {
		"name": "Saiyan Pride I",
		"desc": "Pride fuels power.\n+20% damage, 10% faster fire rate.",
		"color": Color(0.55, 0.35, 1.0)
	},
	"pride_2": {
		"name": "Saiyan Pride II",
		"desc": "Never yield!\n+25% damage to Pride Strike.",
		"color": Color(0.6, 0.4, 1.0)
	},
	"pride_3": {
		"name": "Super Saiyan",
		"desc": "Beyond his rival at last!\n+40% damage to Pride Strike.",
		"color": Color(1.0, 0.9, 0.2)
	},
	"pride_4": {
		"name": "Super Saiyan Blue",
		"desc": "God Ki unlocked.\n+60% damage, 15% faster fire rate.",
		"color": Color(0.3, 0.5, 1.0)
	},
	"pride_5": {
		"name": "Royal Volley",
		"desc": "Five-bolt barrage!\n+50% damage, 5 shots per volley.",
		"color": Color(0.4, 0.6, 1.0)
	},
	"pride_limit_break": {
		"name": "Galick Gun!",
		"desc": "GALICK GUN — rival of Kamehameha!\n×2 damage, 30% faster fire rate.",
		"color": Color(0.7, 0.2, 1.0)
	},
	"ssb_evolved": {
		"name": "SSB Evolved",
		"desc": "Beyond gods — surpassing rivals!\n×3 damage, azure energy bolts.",
		"color": Color(0.1, 0.4, 1.0)
	},
	# ── Dragon Ball: Gohan — Potential Path ──────────────────────────────────
	"gohan_masenko": {
		"name": "Masenko",
		"desc": "Gohan fires a wide energy wave\nthat hits multiple enemies. [Potential Path]",
		"color": Color(0.8, 0.2, 1.0)
	},
	"gohan_1": {
		"name": "Unleashed I",
		"desc": "Hidden power stirs within.\n+20% damage to Masenko.",
		"color": Color(0.85, 0.35, 1.0)
	},
	"gohan_2": {
		"name": "Unleashed II",
		"desc": "Potential grows!\n+25% damage, 5-wave burst.",
		"color": Color(0.9, 0.5, 1.0)
	},
	"gohan_3": {
		"name": "Scholar's Power",
		"desc": "Studies meet raw strength.\n+40% damage to Masenko.",
		"color": Color(0.95, 0.6, 0.2)
	},
	"gohan_4": {
		"name": "Ultimate Gohan",
		"desc": "Full potential reached!\n+60% damage to Masenko.",
		"color": Color(1.0, 0.7, 0.2)
	},
	"gohan_5": {
		"name": "Son of Goku",
		"desc": "Father's legacy burns bright!\n+50% damage, 7-wave burst.",
		"color": Color(1.0, 0.8, 0.25)
	},
	"gohan_limit_break": {
		"name": "Father-Son Kamehameha",
		"desc": "With father's spirit guiding him!\n×2 damage, 30% faster fire rate.",
		"color": Color(0.6, 0.85, 1.0)
	},
	"gohan_beast": {
		"name": "Gohan Beast",
		"desc": "The beast within roars!\n×3 damage, 9-wave crimson burst.",
		"color": Color(0.9, 0.1, 0.15)
	},
	# ── Dragon Ball: Piccolo — Namekian Path ─────────────────────────────────
	"namekian_arm": {
		"name": "Namekian Arm",
		"desc": "Piccolo's stretching arm orbits you,\nstriking enemies continuously. [Namekian Path]",
		"color": Color(0.1, 0.7, 0.2)
	},
	"namekian_1": {
		"name": "Namekian Might I",
		"desc": "Ancient warrior training.\n+20% damage to Namekian Arm.",
		"color": Color(0.15, 0.75, 0.25)
	},
	"namekian_2": {
		"name": "Namekian Might II",
		"desc": "Stretching farther!\n+25% damage to Namekian Arm.",
		"color": Color(0.2, 0.8, 0.3)
	},
	"namekian_3": {
		"name": "Mystic Regeneration",
		"desc": "Namekian healing power!\n+40% damage + restore 30 HP.",
		"color": Color(0.25, 0.85, 0.35)
	},
	"namekian_4": {
		"name": "Two Arms",
		"desc": "Dual stretching arms orbit!\n+50% damage, 2 orbiting arms.",
		"color": Color(0.3, 0.9, 0.4)
	},
	"namekian_5": {
		"name": "Three Arms",
		"desc": "Triple arm assault!\n+50% damage, 3 orbiting arms.",
		"color": Color(0.35, 0.95, 0.45)
	},
	"namekian_limit_break": {
		"name": "Special Beam Cannon",
		"desc": "Makankōsappō — drilling pierce!\n×2 damage to Namekian Arm.",
		"color": Color(0.1, 0.95, 0.5)
	},
	"unlocked_namekian": {
		"name": "Potential Unlocked",
		"desc": "Orange Piccolo — true potential!\n×3 damage, 4 orbiting arms.",
		"color": Color(0.9, 0.5, 0.1)
	},
	# ── Dragon Ball: Frieza — Tyrant Path ────────────────────────────────────
	"death_beam": {
		"name": "Death Beam",
		"desc": "Frieza fires a rapid piercing beam\nthrough enemies. [Tyrant Path]",
		"color": Color(0.7, 0.1, 0.8)
	},
	"tyrant_1": {
		"name": "Tyrant's Will I",
		"desc": "Ruthless precision.\n+20% damage, 15% faster fire rate.",
		"color": Color(0.75, 0.2, 0.85)
	},
	"tyrant_2": {
		"name": "Tyrant's Will II",
		"desc": "None shall defy him!\n+25% damage, 20% faster fire rate.",
		"color": Color(0.8, 0.3, 0.9)
	},
	"tyrant_3": {
		"name": "100% Power",
		"desc": "Frieza at maximum strength!\n+50% damage to Death Beam.",
		"color": Color(0.85, 0.4, 0.95)
	},
	"tyrant_4": {
		"name": "Golden Frieza",
		"desc": "Golden form — godlike power!\n+60% damage, 25% faster fire rate.",
		"color": Color(1.0, 0.8, 0.1)
	},
	"tyrant_5": {
		"name": "Death Volley",
		"desc": "Triple-beam barrage!\n+50% damage, 3 beams per shot.",
		"color": Color(0.9, 0.5, 1.0)
	},
	"tyrant_limit_break": {
		"name": "Death Ball!",
		"desc": "Galaxy-destroying Death Ball!\n×2 damage to Death Beam.",
		"color": Color(0.6, 0.0, 0.7)
	},
	"black_frieza": {
		"name": "Black Frieza",
		"desc": "10 years in the Time Chamber.\n×3 damage, unstoppable black beams.",
		"color": Color(0.15, 0.0, 0.2)
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
	_offered_ids = _pick_abilities(3, already_owned)
	for id in _offered_ids:
		_create_card(id)
	visible = true
	get_tree().paused = true

func _pick_abilities(count: int, owned: Array) -> Array[String]:
	var pool := ABILITIES.keys().duplicate()
	# Exclude already-owned one-time abilities and unmet prerequisites
	pool = pool.filter(func(id: String) -> bool:
		if id in ONCE_ONLY and id in owned:
			return false
		if PREREQUISITES.has(id) and not (PREREQUISITES[id] in owned):
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
