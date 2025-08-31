extends Node2D

@export var move_speed: float = 200.0

var target_position: Vector2
var moving: bool = false

func _ready() -> void:
	target_position = global_position

func _process(delta: float) -> void:
	if moving:
		var direction = (target_position - global_position).normalized()
		var distance = move_speed * delta

		if global_position.distance_to(target_position) <= distance:
			global_position = target_position
			moving = false
		else:
			global_position += direction * distance

func move_to(tile_coords: Vector2i, board: TileMap) -> void:
	target_position = board.map_to_world(tile_coords) + board.tile_set.tile_size / 2
	moving = true
