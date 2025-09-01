extends Node
class_name PlayerStats

# --- Base stats ---
@export var max_health: int = 100
var current_health: int = max_health
@export var strength: int = 10
@export var defense: int = 5
@export var speed: int = 5

# --- Equipment modifiers (optional) ---
var weapon_bonus_strength: int = 0
var armor_bonus_defense: int = 0

# --- Initialization ---
func _ready() -> void:
	current_health = max_health

# --- Health functions ---
func take_damage(amount: int) -> void:
	var damage_taken = max(amount - (defense + armor_bonus_defense), 0)
	current_health = max(current_health - damage_taken, 0)
	print("Damage taken:", damage_taken, "Current health:", current_health)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Healed:", amount, "Current health:", current_health)

func is_alive() -> bool:
	return current_health > 0

# --- Combat functions ---
func attack_roll() -> int:
	# Simple attack roll: strength + weapon bonus + dice roll (1-6)
	return strength + weapon_bonus_strength + randi_range(1, 6)

func get_total_defense() -> int:
	return defense + armor_bonus_defense

# --- Equipment functions ---
func equip_weapon(strength_bonus: int) -> void:
	weapon_bonus_strength = strength_bonus
	print("Weapon equipped. Strength bonus:", weapon_bonus_strength)

func equip_armor(defense_bonus: int) -> void:
	armor_bonus_defense = defense_bonus
	print("Armor equipped. Defense bonus:", armor_bonus_defense)

# --- Utility / debug ---
func print_stats() -> void:
	print("Health:", current_health, "/", max_health,
		  " Strength:", strength + weapon_bonus_strength,
		  " Defense:", defense + armor_bonus_defense,
		  " Speed:", speed)
