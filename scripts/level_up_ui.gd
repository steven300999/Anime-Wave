extends CanvasLayer

signal ability_chosen(ability_id: String)

@onready var card_container: HBoxContainer = $Overlay/Panel/VBox/Cards
@onready var level_up_label: Label = $Overlay/Panel/VBox/TitleLabel

var _path_levels: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_choices(level: int, path_levels: Dictionary, has_evolution: bool) -> void:
	level_up_label.text = "Level Up! — Lv. %d\nChoose Your Goofy Power" % level
	_path_levels = path_levels.duplicate(true)
	_clear_cards()
	for entry in _pick_choices(3, has_evolution):
		_create_card(entry)
	visible = true
	get_tree().paused = true

func _pick_choices(count: int, has_evolution: bool) -> Array:
	var style_pool: Array = []
	for style_id in StyleData.STYLE_ORDER:
		var current: int = _path_levels.get(style_id, 0)
		if current >= 7:
			continue
		var next_level := current + 1
		if next_level == 7 and has_evolution:
			continue
		style_pool.append({"id": style_id, "type": "style", "next_level": next_level})

	var pickup_pool: Array = []
	for pickup_id in StyleData.PICKUPS.keys():
		pickup_pool.append({"id": pickup_id, "type": "pickup", "next_level": 1})

	style_pool.shuffle()
	pickup_pool.shuffle()

	var combined: Array = []
	if not style_pool.is_empty():
		combined.append(style_pool.pop_front())
	combined.append_array(style_pool)
	combined.append_array(pickup_pool)

	var result: Array = []
	for entry in combined:
		if result.size() >= count:
			break
		result.append(entry)
	return result

func _clear_cards() -> void:
	for child in card_container.get_children():
		child.queue_free()

func _create_card(entry: Dictionary) -> void:
	var id: String = entry["id"]
	var is_style := entry["type"] == "style"
	var card_color := Color(0.8, 0.8, 0.8)
	var name := ""
	var desc := ""
	var subtitle := ""
	var tier := "Pickup"

	if is_style:
		var next_level: int = entry["next_level"]
		var style_data: Dictionary = StyleData.STYLES[id]
		var level_data: Dictionary = style_data["levels"][next_level]
		card_color = style_data["color"]
		name = level_data["name"]
		desc = level_data["desc"]
		subtitle = "%s Path • Lv.%d" % [style_data["path_name"], next_level]
		tier = level_data.get("tier", "Upgrade")
	else:
		var pickup: Dictionary = StyleData.PICKUPS[id]
		card_color = pickup["color"]
		name = pickup["name"]
		desc = pickup["desc"]
		subtitle = "Quick Buff"
		tier = pickup.get("tier", "Pickup")

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(250, 210)
	btn.process_mode = Node.PROCESS_MODE_ALWAYS
	btn.text = ""
	card_container.add_child(btn)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 6)
	btn.add_child(vbox)

	var badge := Label.new()
	badge.text = tier.to_upper()
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 12)
	badge.add_theme_color_override("font_color", StyleData.TIER_COLORS.get(tier, Color(0.85, 0.85, 0.85)))
	vbox.add_child(badge)

	var title := Label.new()
	title.text = name
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", card_color)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(title)

	var sub := Label.new()
	sub.text = subtitle
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 12)
	sub.add_theme_color_override("font_color", Color(0.7, 0.75, 0.85))
	vbox.add_child(sub)

	vbox.add_child(HSeparator.new())

	var desc_label := Label.new()
	desc_label.text = desc
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.9))
	vbox.add_child(desc_label)

	btn.pressed.connect(_on_card_pressed.bind(id))

func _on_card_pressed(ability_id: String) -> void:
	get_tree().paused = false
	visible = false
	ability_chosen.emit(ability_id)
