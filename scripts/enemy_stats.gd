extends Node
class_name EnemyStats

var max_health: int
var current_health: int
var strength: int
var defense: int
var speed: int

var health_scaling = 0.2
var stat_scaling = 0.1

func setup(data: EnemyData) -> void:
	var loop = GameData.loop_count
	var health_mult = 1.0 + (loop * health_scaling)   # +20% HP per loop
	var stat_mult = 1.0 + (loop * stat_scaling)      # +10% str/def per loop

	max_health = int(data.max_health * health_mult)
	current_health = max_health
	strength = int(data.strength * stat_mult)
	defense = int(data.defense * stat_mult)
	speed = data.speed  # speed stays flat, keeps combat predictable
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
	
