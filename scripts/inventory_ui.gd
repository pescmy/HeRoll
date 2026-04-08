# inventory_ui.gd
extends CanvasLayer

@onready var grid: GridContainer = $Panel/VBoxContainer/GridContainer

var slot_nodes: Array = []

func _ready() -> void:
	GameData.inventory_changed.connect(update_display)
	_build_slots()
	update_display()
	_setup_layout()
	hide()

func _setup_layout() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	style.border_width_left = -2
	style.border_width_right = -2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5, 1.0)
	$Panel.add_theme_stylebox_override("panel", style)
	
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = Vector2(400, 300)
	var pos = (viewport_size - panel_size) / 2
	pos.y += 50
	$Panel.set_position(pos)
	$Panel.set_size(panel_size)
	
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(64, 64)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if visible:
			hide()
		else:
			show()

func _build_slots() -> void:
	for i in range(GameData.inventory_size):
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(64, 64)
		panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		var overlay = Control.new()
		overlay.name = "Overlay"
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		var texture_rect = TextureRect.new()
		texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.name = "Icon"
		
		var label = Label.new()
		label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		label.grow_vertical = Control.GROW_DIRECTION_BEGIN
		label.name = "Amount"
		label.add_theme_color_override("font_color", Color.RED)
		
		overlay.add_child(texture_rect)
		overlay.add_child(label)
		panel.add_child(overlay)
		grid.add_child(panel)
		slot_nodes.append(panel)

func update_display() -> void:
	for i in range(GameData.inventory_size):
		var slot = GameData.inventory[i]
		var panel = slot_nodes[i]
		var icon = panel.get_node("Overlay/Icon")
		var label = panel.get_node("Overlay/Amount")
		
		if slot.is_empty():
			icon.texture = null
			label.text = ""
		else:
			icon.texture = load(slot["icon"])
			if slot["type"] == "resource":
				label.text = str(slot["amount"])
			else:
				label.text = ""
