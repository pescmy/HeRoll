# town.gd
extends Node2D

@onready var gold_label: Label = $UI/VBoxContainer/Storage/GoldLabel
@onready var wood_label: Label = $UI/VBoxContainer/Storage/WoodLabel
@onready var stone_label: Label = $UI/VBoxContainer/Storage/StoneLabel
@onready var buildings_container: VBoxContainer = $UI/VBoxContainer/Buildings
@onready var start_run_button: Button = $UI/VBoxContainer/StartRunButton

const BUILDING_COSTS = {
	"blacksmith": {"gold": 1, "wood": 1, "stone": 1},
	#"blacksmith": {"gold": 50, "wood": 30, "stone": 10},
	"armoury": {"gold": 50, "wood": 10, "stone": 30},
	"jeweller": {"gold": 80, "wood": 20, "stone": 20},
	"apothecary": {"gold": 40, "wood": 30, "stone": 10},
	"training_grounds": {"gold": 40, "wood": 30, "stone": 30},
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

func _ready() -> void:
	TownData.town_storage_changed.connect(refresh)
	TownData.building_constructed.connect(_on_building_constructed)
	start_run_button.pressed.connect(_on_start_run_pressed)
	_build_building_rows()
	refresh()

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
		button.pressed.connect(_on_build_pressed.bind(building_name))
		hbox.add_child(button)

		buildings_container.add_child(hbox)

func _refresh_building_buttons() -> void:
	for building_name in BUILDING_COSTS:
		var hbox = buildings_container.get_node(building_name)
		var label: Label = hbox.get_node("Label")
		var button: Button = hbox.get_node("Button")
		var cost = BUILDING_COSTS[building_name]
		var built = TownData.buildings.get(building_name, false)

		label.text = BUILDING_LABELS[building_name]

		if built:
			button.text = "Built"
			button.disabled = true
		else:
			button.text = "Build (%dg/%dw/%ds)" % [cost["gold"], cost["wood"], cost["stone"]]
			button.disabled = not TownData.can_afford(cost)

func _on_build_pressed(building_name: String) -> void:
	TownData.construct_building(building_name, BUILDING_COSTS[building_name])

func _on_building_constructed(_building_name: String) -> void:
	_refresh_building_buttons()

func _on_start_run_pressed() -> void:
	GameData.reset_run()
	SaveManager.save()
	get_tree().change_scene_to_file("res://scene/game.tscn")
