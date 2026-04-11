# town.gd
extends Node2D

@onready var gold_label: Label = $UI/VBoxContainer/Storage/GoldLabel
@onready var wood_label: Label = $UI/VBoxContainer/Storage/WoodLabel
@onready var stone_label: Label = $UI/VBoxContainer/Storage/StoneLabel
@onready var buildings_container: VBoxContainer = $UI/VBoxContainer/Buildings
@onready var start_run_button: Button = $UI/VBoxContainer/StartRunButton
@onready var building_panel: PanelContainer = $UI/BuildingPanel
@onready var building_panel_title: Label = $UI/BuildingPanel/VBoxContainer/Title
@onready var upgrade_level_label: Label = $UI/BuildingPanel/VBoxContainer/UpgradeLevel
@onready var upgrade_cost_label: Label = $UI/BuildingPanel/VBoxContainer/UpgradeCost
@onready var upgrade_bonus_label: Label = $UI/BuildingPanel/VBoxContainer/UpgradeBonus
@onready var upgrade_button: Button = $UI/BuildingPanel/VBoxContainer/UpgradeButton
@onready var close_panel_button: Button = $UI/BuildingPanel/VBoxContainer/CloseButton

const BUILDING_COSTS = {
	"blacksmith": {"gold": 50, "wood": 30, "stone": 0},
	"armoury": {"gold": 50, "wood": 0, "stone": 30},
	"jeweller": {"gold": 80, "wood": 20, "stone": 20},
	"apothecary": {"gold": 40, "wood": 30, "stone": 0},
	"training_grounds": {"gold": 40, "wood": 0, "stone": 30},
	"town_vault": {"gold": 60, "wood": 20, "stone": 20},
}

const BUILDING_LABELS = {
	"blacksmith": "Blacksmith (Weapons)",
	"armoury": "Armoury (Armour)",
	"jeweller": "Jeweller (Accessories)",
	"apothecary": "Apothecary (Health)",
	"training_grounds": "Training Grounds (Speed)",
	"town_vault": "Town Vault (Storage)",
}

const UPGRADE_LABELS = {
	"blacksmith": "Strength",
	"armoury": "Defense",
	"jeweller": "Speed",
	"apothecary": "Max Health",
	"training_grounds": "Speed",
	"town_vault": "Inventory Slots",
}

var selected_building: String = ""

func _ready() -> void:
	# DEBUG - remove before release
	if TownData.town_storage["gold"] == 0:
		TownData.town_storage["gold"] = 200
		TownData.town_storage["wood"] = 200
		TownData.town_storage["stone"] = 200
	
	TownData.town_storage_changed.connect(refresh)
	TownData.building_constructed.connect(_on_building_constructed)
	TownData.upgrade_purchased.connect(_on_upgrade_purchased)
	start_run_button.pressed.connect(_on_start_run_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	close_panel_button.pressed.connect(_close_building_panel)
	building_panel.hide()
	_build_building_rows()
	refresh()
	_update_start_button()

func refresh() -> void:
	gold_label.text = "Gold: %d" % TownData.town_storage.get("gold", 0)
	wood_label.text = "Wood: %d" % TownData.town_storage.get("wood", 0)
	stone_label.text = "Stone: %d" % TownData.town_storage.get("stone", 0)
	_refresh_building_buttons()

func _build_building_rows() -> void:
	for building_name in BUILDING_COSTS:
		var hbox = HBoxContainer.new()
		hbox.name = building_name

		var label = Label.new()
		label.name = "Label"
		label.custom_minimum_size = Vector2(260, 0)
		hbox.add_child(label)

		var button = Button.new()
		button.name = "Button"
		button.pressed.connect(_on_building_button_pressed.bind(building_name))
		hbox.add_child(button)

		buildings_container.add_child(hbox)

func _refresh_building_buttons() -> void:
	for building_name in BUILDING_COSTS:
		var hbox = buildings_container.get_node(building_name)
		var label: Label = hbox.get_node("Label")
		var button: Button = hbox.get_node("Button")
		var cost = BUILDING_COSTS[building_name]
		var built = TownData.buildings.get(building_name, false)
		var level = TownData.get_upgrade_level(building_name)

		label.text = BUILDING_LABELS[building_name]

		if built:
			button.text = "Enter (Lvl %d/%d)" % [level, TownData.MAX_UPGRADE_LEVEL]
			button.disabled = false
		else:
			button.text = "Build (%dg/%dw/%ds)" % [cost["gold"], cost["wood"], cost["stone"]]
			button.disabled = not TownData.can_afford(cost)

func _on_building_button_pressed(building_name: String) -> void:
	if building_panel.visible:
		return
	if TownData.buildings[building_name]:
		_open_building_panel(building_name)
	else:
		TownData.construct_building(building_name, BUILDING_COSTS[building_name])

func _open_building_panel(building_name: String) -> void:
	selected_building = building_name
	_refresh_building_panel()
	building_panel.show()
	
	start_run_button.disabled = true
	for b in BUILDING_COSTS:
		buildings_container.get_node(building_name).get_node("Button").disabled = true

func _refresh_building_panel() -> void:
	if selected_building == "":
		return
	var level = TownData.get_upgrade_level(selected_building)
	var cost = TownData.get_upgrade_cost(selected_building)
	var bonus = TownData.get_upgrade_bonus(TownData.BUILDING_UPGRADES[selected_building])
	var stat = UPGRADE_LABELS[selected_building]

	building_panel_title.text = BUILDING_LABELS[selected_building]
	upgrade_level_label.text = "Level: %d / %d" % [level, TownData.MAX_UPGRADE_LEVEL]
	upgrade_bonus_label.text = "Current bonus: +%d %s" % [bonus, stat]

	if level >= TownData.MAX_UPGRADE_LEVEL:
		upgrade_cost_label.text = "Max level reached"
		upgrade_button.disabled = true
	else:
		upgrade_cost_label.text = "Next level: %d gold" % cost
		upgrade_button.disabled = TownData.town_storage["gold"] < cost

func _on_upgrade_pressed() -> void:
	TownData.purchase_upgrade(selected_building)
	_refresh_building_panel()

func _on_upgrade_purchased(_key: String) -> void:
	_refresh_building_buttons()

func _on_building_constructed(_building_name: String) -> void:
	_refresh_building_buttons()

func _close_building_panel() -> void:
	selected_building = ""
	building_panel.hide()
	start_run_button.disabled = false
	_refresh_building_buttons()

func _update_start_button() -> void:
	if GameData.player_tile_index > 0:
		start_run_button.text = "Continue Run"
	else:
		start_run_button.text = "Start Run"

func _on_start_run_pressed() -> void:
	if GameData.player_tile_index == 0:
		GameData.reset_run()
		SaveManager.save()
	get_tree().change_scene_to_file("res://scene/game.tscn")

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	if Input.is_action_just_pressed("ui_accept"):
		_on_start_run_pressed()
