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
	max_health = base_health + TownData.get_upgrade_bonus("apothecary_health")
	strength = base_strength + TownData.get_upgrade_bonus("blacksmith_strength")
	defense = base_defense + TownData.get_upgrade_bonus("armoury_defense")
	speed = base_speed + TownData.get_upgrade_bonus("jeweller_speed") + TownData.get_upgrade_bonus("training_grounds_speed")

	if equipment.equipped_weapon:
		apply_item(equipment.equipped_weapon)
	if equipment.equipped_armour:
		apply_item(equipment.equipped_armour)
	if equipment.equipped_accessory:
		apply_item(equipment.equipped_accessory)

	if GameData.player_current_health == -1:
		current_health = max_health
	else:
		current_health = GameData.player_current_health
		print("💾 Restoring health: %d" % current_health)
	
	GameData.player_max_health = max_health
	print("Final stats => HP: %d/%d, Str: %d, Def: %d, Spd: %d" % [current_health, max_health, strength, defense, speed])

func apply_item(item: Item) -> void:
	max_health += item.health_bonus
	strength += item.strength_bonus
	defense += item.defense_bonus
	speed += item.speed_bonus

# --- Combat helpers ---
func take_damage(amount: int) -> int:
	var damage = max(amount - defense, 1)
	current_health = max(current_health - damage, 0)
	print("🛡️ Player absorbed %d, took %d damage! HP: %d/%d" % [amount - damage, damage, current_health, max_health])
	return damage

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Player heals %d! HP: %d/%d" % [amount, current_health, max_health])

func is_dead() -> bool:
	return current_health <= 0

func get_attack_damage() -> int:
	return strength + randi_range(1, 6)
