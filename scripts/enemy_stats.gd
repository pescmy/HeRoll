extends Node
class_name EnemyStats

var max_health: int
var current_health: int
var strength: int
var defense: int
var speed: int

func setup(data: EnemyData) -> void:
	max_health = data.max_health
	current_health = data.max_health
	strength = data.strength
	defense = data.defense
	speed = data.speed
	print("Enemy stats loaded: HP %d/%d, Str %d, Def %d, Spd %d" % [current_health, max_health, strength, defense, speed])

func take_damage(amount: int) -> void:
	var damage: int = max(amount - defense, 1)
	current_health = max(current_health - damage, 0)
	print("Enemy took %d damage! HP: %d/%d" % [damage, current_health, max_health])

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)
	print("Enemy healed %d! HP: %d/%d" % [amount, current_health, max_health])

func is_dead() -> bool:
	return current_health <= 0

func get_attack_damage() -> int:
	return strength + randi_range(1,6)
	
