extends Node
class_name PlayerStats

# --- Base stats (without equipment) ---
@export var base_health: int = 100
@export var base_strength: int = 10
@export var base_defense: int = 5
@export var base_speed: int = 5

# --- Final stats (calculated) ---
var health: int
var strength: int
var defense: int
var speed: int

func calculate_final_stats(equipment: Node) -> void:
	# Reset to base stats
	health = base_health
	strength = base_strength
	defense = base_defense
	speed = base_speed

	# Add bonuses from equipment if present
	if equipment.equipped_weapon:
		apply_item(equipment.equipped_weapon)
	if equipment.equipped_armor:
		apply_item(equipment.equipped_armor)
	if equipment.equipped_accessory:
		apply_item(equipment.equipped_accessory)

	print("Final stats => Health: %d, Str: %d, Def: %d, Spd: %d" % [health, strength, defense, speed])

func apply_item(item: Item) -> void:
	health += item.health_bonus
	strength += item.strength_bonus
	defense += item.defense_bonus
	speed += item.speed_bonus
