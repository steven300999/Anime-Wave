extends CanvasLayer

signal ability_chosen(ability_id: String)

const ONCE_ONLY := ["rasengan", "water_breathing", "cursed_energy"]

# One Piece path identifiers (base-weapon ID for each character)
const OP_BASE_IDS := [
	"luffy_gum_gum", "zoro_three_sword", "sanji_black_leg",
	"nami_weather", "robin_devil_fruit",
]

# Full upgrade chain per character: [base, up1..up5, limit_break, evolution]
const OP_CHAINS := {
	"luffy": [
		"luffy_gum_gum",
		"luffy_up_1", "luffy_up_2", "luffy_up_3", "luffy_up_4", "luffy_up_5",
		"luffy_lb", "luffy_evo",
	],
	"zoro": [
		"zoro_three_sword",
		"zoro_up_1", "zoro_up_2", "zoro_up_3", "zoro_up_4", "zoro_up_5",
		"zoro_lb", "zoro_evo",
	],
	"sanji": [
		"sanji_black_leg",
		"sanji_up_1", "sanji_up_2", "sanji_up_3", "sanji_up_4", "sanji_up_5",
		"sanji_lb", "sanji_evo",
	],
	"nami": [
		"nami_weather",
		"nami_up_1", "nami_up_2", "nami_up_3", "nami_up_4", "nami_up_5",
		"nami_lb", "nami_evo",
	],
	"robin": [
		"robin_devil_fruit",
		"robin_up_1", "robin_up_2", "robin_up_3", "robin_up_4", "robin_up_5",
		"robin_lb", "robin_evo",
	],
}

const ABILITIES := {
	# ── Existing abilities ─────────────────────────────────────────────
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
	# ── One Piece — Luffy (Gum Gum) ────────────────────────────────────
	"luffy_gum_gum": {
		"name": "Luffy – Gum Gum Pistol",
		"desc": "Rubber-fist projectiles fired toward\nthe nearest enemy.",
		"color": Color(0.95, 0.2, 0.1)
	},
	"luffy_up_1": {
		"name": "Gum Gum: Lv.2 – Barrage",
		"desc": "+5 dmg. Slightly faster fire rate.",
		"color": Color(0.95, 0.2, 0.1)
	},
	"luffy_up_2": {
		"name": "Gum Gum: Lv.3 – Rapid Fire",
		"desc": "Fires 2 fists at once. +5 dmg.",
		"color": Color(0.95, 0.2, 0.1)
	},
	"luffy_up_3": {
		"name": "Gum Gum: Lv.4 – Cannon",
		"desc": "+8 dmg. Faster cooldown.",
		"color": Color(0.95, 0.2, 0.1)
	},
	"luffy_up_4": {
		"name": "Gum Gum: Lv.5 – Kong Gun",
		"desc": "Fires 3 fists. +8 dmg. More speed.",
		"color": Color(0.95, 0.2, 0.1)
	},
	"luffy_up_5": {
		"name": "Gum Gum: Lv.6 – Elephant Gun",
		"desc": "+10 dmg. Maximum bullet speed.",
		"color": Color(0.95, 0.2, 0.1)
	},
	"luffy_lb": {
		"name": "Limit Break: Gear Fourth",
		"desc": "Boundman — ×1.6 dmg, faster rate,\n+1 extra fist per shot.",
		"color": Color(1.0, 0.55, 0.1)
	},
	"luffy_evo": {
		"name": "Gear Fifth – Nika",
		"desc": "5-fist cartoonish barrage.\nMassive dmg, blistering speed.",
		"color": Color(1.0, 1.0, 1.0)
	},
	# ── One Piece — Zoro (Three Sword) ─────────────────────────────────
	"zoro_three_sword": {
		"name": "Zoro – Three Sword Style",
		"desc": "3 sword slashes fan toward\nthe nearest enemy.",
		"color": Color(0.1, 0.65, 0.2)
	},
	"zoro_up_1": {
		"name": "Three Sword: Lv.2 – Oni Giri",
		"desc": "+8 dmg. Faster cooldown.",
		"color": Color(0.1, 0.65, 0.2)
	},
	"zoro_up_2": {
		"name": "Three Sword: Lv.3 – Toro Nagashi",
		"desc": "5 slashes per burst. +6 dmg.",
		"color": Color(0.1, 0.65, 0.2)
	},
	"zoro_up_3": {
		"name": "Three Sword: Lv.4 – Phoenix",
		"desc": "+10 dmg. Faster cooldown.",
		"color": Color(0.1, 0.65, 0.2)
	},
	"zoro_up_4": {
		"name": "Three Sword: Lv.5 – Tiger Hunt",
		"desc": "7 slashes per burst. +10 dmg.",
		"color": Color(0.1, 0.65, 0.2)
	},
	"zoro_up_5": {
		"name": "Three Sword: Lv.6 – Dragon Shock",
		"desc": "+12 dmg. Devastating slash storm.",
		"color": Color(0.1, 0.65, 0.2)
	},
	"zoro_lb": {
		"name": "Limit Break: Asura",
		"desc": "Nine-sword phantasm — ×1.7 dmg,\n9 slashes, faster burst.",
		"color": Color(0.55, 0.9, 0.3)
	},
	"zoro_evo": {
		"name": "King of Hell – Kokuto",
		"desc": "Black-blade slashes ×2.2 dmg.\n12 phantom cuts per burst.",
		"color": Color(0.15, 0.15, 0.1)
	},
	# ── One Piece — Sanji (Black Leg) ──────────────────────────────────
	"sanji_black_leg": {
		"name": "Sanji – Black Leg",
		"desc": "3 rapid kick blasts fanned\ntoward the nearest enemy.",
		"color": Color(0.15, 0.15, 0.35)
	},
	"sanji_up_1": {
		"name": "Black Leg: Lv.2 – Collier",
		"desc": "+5 dmg. Faster fire rate.",
		"color": Color(0.15, 0.15, 0.35)
	},
	"sanji_up_2": {
		"name": "Black Leg: Lv.3 – Mouton Shot",
		"desc": "4 kicks per burst. +5 dmg.",
		"color": Color(0.15, 0.15, 0.35)
	},
	"sanji_up_3": {
		"name": "Black Leg: Lv.4 – Diable Jambe",
		"desc": "Kicks ignite with flame! +8 dmg.",
		"color": Color(1.0, 0.45, 0.0)
	},
	"sanji_up_4": {
		"name": "Black Leg: Lv.5 – Sky Walk",
		"desc": "5 flaming kicks. Faster rate.",
		"color": Color(1.0, 0.45, 0.0)
	},
	"sanji_up_5": {
		"name": "Black Leg: Lv.6 – Ifrit Jambe",
		"desc": "+8 dmg. Maximum kick speed.",
		"color": Color(1.0, 0.45, 0.0)
	},
	"sanji_lb": {
		"name": "Limit Break: Germa Exoskin",
		"desc": "×1.5 dmg, +2 kicks per burst,\nall kicks ignite, much faster.",
		"color": Color(0.85, 0.75, 0.1)
	},
	"sanji_evo": {
		"name": "Raid Suit – Stealth Black",
		"desc": "8 blazing kicks, ultra speed.\n×2 dmg, near-instant cooldown.",
		"color": Color(0.6, 0.6, 0.6)
	},
	# ── One Piece — Nami (Weather) ─────────────────────────────────────
	"nami_weather": {
		"name": "Nami – Weather Staff",
		"desc": "Lightning strikes the nearest enemy\nevery 1.8 seconds.",
		"color": Color(1.0, 0.6, 0.0)
	},
	"nami_up_1": {
		"name": "Weather: Lv.2 – Thunder Charge",
		"desc": "+8 dmg. Faster storm cycle.",
		"color": Color(1.0, 0.6, 0.0)
	},
	"nami_up_2": {
		"name": "Weather: Lv.3 – Tornado Tempo",
		"desc": "2 bolts per strike. +5 dmg.",
		"color": Color(1.0, 0.6, 0.0)
	},
	"nami_up_3": {
		"name": "Weather: Lv.4 – Black Ball",
		"desc": "3 scattered bolts. +8 dmg.\nWider scatter radius.",
		"color": Color(1.0, 0.6, 0.0)
	},
	"nami_up_4": {
		"name": "Weather: Lv.5 – Thunderbolt Tempo",
		"desc": "4 bolts per burst. Faster rate.",
		"color": Color(1.0, 0.6, 0.0)
	},
	"nami_up_5": {
		"name": "Weather: Lv.6 – Zeus Lightning",
		"desc": "+8 dmg. Maximum storm intensity.",
		"color": Color(1.0, 0.6, 0.0)
	},
	"nami_lb": {
		"name": "Limit Break: Climatact Storm",
		"desc": "6 bolts, ×1.6 dmg, much faster,\ngiant scatter radius.",
		"color": Color(1.0, 0.85, 0.2)
	},
	"nami_evo": {
		"name": "Climatact Awakening",
		"desc": "8 awakened purple bolts.\n×2 dmg, rapid-fire tempest.",
		"color": Color(0.85, 0.2, 1.0)
	},
	# ── One Piece — Robin (Devil Fruit) ────────────────────────────────
	"robin_devil_fruit": {
		"name": "Robin – Devil Fruit",
		"desc": "3 arms orbit you, damaging\nenemies they touch.",
		"color": Color(0.25, 0.25, 0.75)
	},
	"robin_up_1": {
		"name": "Devil Fruit: Lv.2 – Clutch",
		"desc": "+5 dmg. 4 orbiting arms.",
		"color": Color(0.25, 0.25, 0.75)
	},
	"robin_up_2": {
		"name": "Devil Fruit: Lv.3 – Snap",
		"desc": "+5 dmg. Arms orbit faster\nand at greater range.",
		"color": Color(0.25, 0.25, 0.75)
	},
	"robin_up_3": {
		"name": "Devil Fruit: Lv.4 – Cien Fleur",
		"desc": "5 orbiting arms. +8 dmg.",
		"color": Color(0.25, 0.25, 0.75)
	},
	"robin_up_4": {
		"name": "Devil Fruit: Lv.5 – Gigantesco Mano",
		"desc": "+8 dmg. Wider orbit, more speed.",
		"color": Color(0.25, 0.25, 0.75)
	},
	"robin_up_5": {
		"name": "Devil Fruit: Lv.6 – Giants' Bloom",
		"desc": "+10 dmg. Maximum orbit size.",
		"color": Color(0.25, 0.25, 0.75)
	},
	"robin_lb": {
		"name": "Limit Break: Demonio Fleur",
		"desc": "8 arms, ×1.6 dmg, larger orbit,\nfaster spin.",
		"color": Color(0.65, 0.2, 1.0)
	},
	"robin_evo": {
		"name": "Demon Child Awakened",
		"desc": "12 demon arms, ×2.2 dmg.\nMassive orbit, blazing speed.",
		"color": Color(0.4, 0.0, 0.65)
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
	pool = pool.filter(func(id: String) -> bool:
		# Standard filter: once-only weapons already owned are excluded
		if id in ONCE_ONLY and id in owned:
			return false
		# One Piece chain gating
		return _is_op_available(id, owned)
	)
	pool.shuffle()
	var result: Array[String] = []
	for id in pool:
		if result.size() >= count:
			break
		result.append(id)
	return result

## Returns true when an ability is available given the current owned set.
## For non-OP abilities this is always true (they pass through to ONCE_ONLY logic).
## For OP base paths: available only while no OP path has been chosen.
## For OP upgrades / limit-breaks / evolutions: available only when the
## immediately preceding chain step is owned and the step itself is not.
func _is_op_available(id: String, owned: Array) -> bool:
	# OP base path — mutually exclusive; available before any path is chosen
	if id in OP_BASE_IDS:
		for base in OP_BASE_IDS:
			if base in owned:
				return false
		return true
	# OP chain step (upgrade 1-5, limit break, evolution)
	for path in OP_CHAINS:
		var chain: Array = OP_CHAINS[path]
		var idx := chain.find(id)
		if idx >= 1:
			# Show only when the previous step is owned and this step is not yet
			return chain[idx - 1] in owned and id not in owned
	# Not an OP ability — always eligible
	return true

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
