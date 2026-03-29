extends Node2D
class_name Enemy

@export var data: EnemyData
@onready var stats: EnemyStats = $EnemyStats

func _ready():
	# If the scene's exported data is set in inspector, apply it.
	if data:
		_apply_data()

func _apply_data():
	name = data.name if data.name != "" else name
	if stats:
		stats.setup(data)
	# optionally: change sprite/animation if data.sprite_path is set
	# var tex = preload(data.sprite_path)  # or load at runtime; be careful with timings

# wrapper API used by BattleController:
func take_damage(amount: int):
	if stats:
		stats.take_damage(amount)

func is_dead() -> bool:
	return stats and stats.is_dead()

func get_attack_damage() -> int:
	return stats.get_attack_damage()
