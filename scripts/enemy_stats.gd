extends Resource
class_name EnemyStats

# --- Base stats (editable in .tres) ---
@export var base_health: int = 50
@export var base_strength: int = 8
@export var base_defense: int = 3
@export var base_speed: int = 4

# --- Runtime stats ---
var max_health: int
var current_health: int
var strength: int
var defense: int
var speed: int

# --- Setup function ---
func setup() -> void:
	max_health = base_health
	current_health = max_health
	strength = base_strength
	defense = base_defense
	speed = base_speed
	print("Enemy ready => HP: %d/%d, Str: %d, Def: %d, Spd: %d" % [current_health, max_health, strength, defense, speed])

# --- Combat helpers ---
func take_damage(amount: int) -> void:
	var damage := max(amount - defense, 1)
	current_health = max(current_health - damage, 0)
	print("Enemy takes %d damage! HP: %d/%d" % [damage, current_health, max_health])

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Enemy heals %d! HP: %d/%d" % [amount, current_health, max_health])

func is_dead() -> bool:
	return current_health <= 0
