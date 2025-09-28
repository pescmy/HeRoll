extends Node2D
class_name Player

@onready var stats: PlayerStats = $PlayerStats
@onready var equipment: PlayerEquipment = $PlayerEquipment

func _ready() -> void:
	# Connect equipment change signal
	equipment.equipment_changed.connect(_on_equipment_changed)
	
	# Initial stat calculation
	stats.calculate_final_stats(equipment)

# Called when equipment changes
func _on_equipment_changed() -> void:
	stats.calculate_final_stats(equipment)

# =======================
# Combat API (BattleController calls these)
# =======================

func take_damage(amount: int) -> void:
	# Damage calculation automatically accounts for equipment via stats
	stats.take_damage(amount)

func heal(amount: int) -> void:
	stats.heal(amount)

func is_dead() -> bool:
	return stats.is_dead()

func get_attack_damage() -> int:
	# Strength from stats already includes equipment bonuses
	return stats.get_attack_damage()

func get_current_health() -> int:
	return stats.current_health

func get_max_health() -> int:
	return stats.max_health
