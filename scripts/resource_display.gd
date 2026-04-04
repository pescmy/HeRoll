# resource_display.gd
extends CanvasLayer
class_name ResourceDisplay

@onready var gold_label: Label = $HBoxContainer/GoldLabel
@onready var wood_label: Label = $HBoxContainer/WoodLabel
@onready var stone_label: Label = $HBoxContainer/StoneLabel

func _ready() -> void:
	GameData.inventory_changed.connect(update_display)
	update_display()

func update_display() -> void:
	gold_label.text = "Gold: %d" % _get_resource_amount("gold")
	wood_label.text = "Wood: %d" % _get_resource_amount("wood")
	stone_label.text = "Stone: %d" % _get_resource_amount("stone")

func _get_resource_amount(resource_name: String) -> int:
	for slot in GameData.inventory:
		if not slot.is_empty() and slot["name"] == resource_name:
			return slot["amount"]
	return 0
