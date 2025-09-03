extends Node2D

@export var enemy_data: EnemyData

@onready var stats = $EnemyStats
@onready var sprite = $Sprite2D

func _ready() -> void:
	if enemy_data:
		stats.setup(enemy_data)
		sprite.texture = enemy_data.sprite
		name = enemy_data.name
		print("Spawned enemy: %s (HP: %d)" % [name, stats.current_health])
