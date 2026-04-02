# resource_display.gd
extends CanvasLayer
class_name ResourceDisplay

@onready var gold_label: Label = $HBoxContainer/GoldLabel
@onready var wood_label: Label = $HBoxContainer/WoodLabel
@onready var stone_label: Label = $HBoxContainer/StoneLabel

func _ready() -> void:
	GameData.resources_changed.connect(update_display)
	update_display()
	print("ResourceDisplay ready and connected")

func update_display() -> void:
	print("Updating resource display")
	gold_label.text = "Gold: %d" % GameData.carried_resources["gold"]
	wood_label.text = "Wood: %d" % GameData.carried_resources["wood"]
	stone_label.text = "Stone: %d" % GameData.carried_resources["stone"]
