extends Resource
class_name EnemyData

@export var name: String
@export var max_health: int
@export var strength: int
@export var defense: int
@export var speed: int
@export var sprite: Texture2D
@export var reward_gold: int
@export var reward_xp: int

func get_threat() -> float:
	return (max_health / 20.0) + (strength * 0.5) + (defense * 0.3) + (speed * 0.2)

func get_min_loop() -> int:
	var threat = get_threat()
	if threat < 8:
		return 0
	elif threat < 13:
		return 2
	else:
		return 4
