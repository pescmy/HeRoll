extends Node

var max_health: int
var current_health: int
var strength: int
var defense: int
var speed: int

func setup(data) -> void:
	max_health = data.max_health
	current_health = max_health
	strength = data.strength
	defense = data.defense
	speed = data.speed

func take_damage(amount: int) -> void:
	var reduced = max(amount - defense, 0)
	current_health = max(current_health - reduced, 0)
	print("%s takes %d damage (HP: %d/%d)" % [owner.name, reduced, current_health, max_health])

func is_dead() -> bool:
	return current_health <= 0
