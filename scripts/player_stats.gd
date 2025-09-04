extends Node
class_name PlayerStats

# --- Base stats (without equipment) ---
@export var base_health: int = 100
@export var base_strength: int = 10
@export var base_defense: int = 5
@export var base_speed: int = 5

# --- Final stats (calculated) ---
var max_health: int
var current_health: int
var strength: int
var defense: int
var speed: int

# --- Setup ---
func calculate_final_stats(equipment: Node) -> void:
	# Reset to base stats
	max_health = base_health
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

	# Start combat health at max
	current_health = max_health

	print("Final stats => HP: %d/%d, Str: %d, Def: %d, Spd: %d" % [current_health, max_health, strength, defense, speed])

func apply_item(item: Item) -> void:
	max_health += item.health_bonus
	strength += item.strength_bonus
	defense += item.defense_bonus
	speed += item.speed_bonus

# --- Combat helpers ---
func take_damage(amount: int) -> void:
	var damage = max(amount - defense, 1) # at least 1 dmg
	current_health = max(current_health - damage, 0)
	print("Player takes %d damage! HP: %d/%d" % [damage, current_health, max_health])

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Player heals %d! HP: %d/%d" % [amount, current_health, max_health])

func is_dead() -> bool:
	return current_health <= 0
