extends Node
class_name PlayerEquipment

@onready var stats: PlayerStats = null

# --- Equipment slots ---
var weapon: Dictionary = {}   # Example: {"name": "Sword", "strength_bonus": 5}
var armor: Dictionary = {}    # Example: {"name": "Leather", "defense_bonus": 3}

func _ready() -> void:
	# Automatically find PlayerStats if not assigned
	if stats == null:
		stats = get_parent().get_node_or_null("PlayerStats")
	if stats == null:
		push_error("PlayerStats not found! Please assign manually.")

# --- Equip functions ---
func equip_weapon(item: Dictionary) -> void:
	weapon = item
	if stats != null:
		var bonus = item.get("strength_bonus", 0)
		stats.equip_weapon(bonus)
		print("Equipped weapon:", item.get("name", "Unknown"), "Bonus:", bonus)

func equip_armor(item: Dictionary) -> void:
	armor = item
	if stats != null:
		var bonus = item.get("defense_bonus", 0)
		stats.equip_armor(bonus)
		print("Equipped armor:", item.get("name", "Unknown"), "Bonus:", bonus)

# --- Unequip functions ---
func unequip_weapon() -> void:
	weapon = {}
	if stats != null:
		stats.equip_weapon(0)
	print("Weapon unequipped")

func unequip_armor() -> void:
	armor = {}
	if stats != null:
		stats.equip_armor(0)
	print("Armor unequipped")

# --- Utility functions ---
func print_equipment() -> void:
	print("Weapon:", weapon.get("name", "None"), "Armor:", armor.get("name", "None"))
