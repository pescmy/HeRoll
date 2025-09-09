extends Node2D

@export var enemy_data: EnemyData   # <--- This makes it show in inspector

var current_health: int

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if enemy_data:
		current_health = enemy_data.max_health
		sprite.texture = enemy_data.sprite
		name = enemy_data.name
		print("Spawned enemy: %s (HP: %d)" % [name, current_health])
