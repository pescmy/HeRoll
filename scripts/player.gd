extends Node2D

@onready var stats = $PlayerStats
@onready var equipment = $PlayerEquipment

func _ready() -> void:
	equipment.equipment_changed.connect(_on_equipment_changed)
	# Calculate stats at the start
	stats.calculate_final_stats(equipment)

func _on_equipment_changed() -> void:
	stats.calculate_final_stats(equipment)


# Load test items
var sword: Item = preload("res://items/weapons/iron_sword.tres")
var armor: Item = preload("res://items/armour/leather_armour.tres")
var ring: Item = preload("res://items/accessory/boots.tres")

func _input(event):
	if event.is_action_pressed("ui_accept"): # Enter
		equipment.equip(sword)
		print("Equipped Sword")
		print(equipment.get_equipment_summary())

	if event.is_action_pressed("ui_cancel"): # Esc
		equipment.equip(armor)
		print("Equipped Armor")
		print(equipment.get_equipment_summary())

	if event.is_action_pressed("ui_right"): # Right arrow
		equipment.equip(ring)
		print("Equipped Accessory")
		print(equipment.get_equipment_summary())
