extends Node
class_name EnemyStats

var max_health: int
var current_health: int
var strength: int
var defense: int
var speed: int

func setup(data: EnemyData) -> void:
	max_health = data.base_health
	current_health = max_health
	strength = data.base_strength
	defense = data.base_defense
	speed = data.base_speed
	print("Stats loaded: HP %d/%d, Str %d, Def %d, Spd %d" % [current_health, max_health, strength, defense, speed])

func take_damage(amount: int) -> void:
	var damage: int = max(amount - defense, 1)
	current_health = max(current_health - damage, 0)
	print("Took %d damage! HP: %d/%d" % [damage, current_health, max_health])

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Healed %d! HP: %d/%d" % [amount, current_health, max_health])

func is_dead() -> bool:
	return current_health <= 0
