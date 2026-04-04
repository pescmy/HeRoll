# board_icons.gd
extends Node2D
class_name BoardIcons

@export var tile_size: int = 32
@export var grid_size: int = 10
@export var board_offset: Vector2 = Vector2(-tile_size*grid_size / 2 + tile_size / 2, -tile_size*grid_size / 2 + tile_size / 2)
@export var icon_scale: Vector2 = Vector2(1, 1)

var icon_map: Dictionary = {
	"combat": preload("res://art/board/sword-clash.png"),
	"shop": preload("res://art/board/shop.png"),
	"resource": preload("res://art/board/gems.png")
}

func _ready() -> void:
	generate_icons()

func generate_icons() -> void:
	#print("🗺️ Generating icons, tile_types: ", GameData.tile_types)
	var positions = get_tile_positions()
	
	for index in GameData.tile_types:
		var type = GameData.tile_types[index]
		if not icon_map.has(type):
			continue
		
		var sprite = Sprite2D.new()
		sprite.texture = icon_map[type]
		sprite.position = positions[index]
		sprite.scale = icon_scale
		add_child(sprite)

func get_tile_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	for col in range(grid_size):
		positions.append(board_offset + Vector2(col * tile_size, 0))
	
	for row in range(1, grid_size):
		positions.append(board_offset + Vector2((grid_size - 1) * tile_size, row * tile_size))
	
	for col in range(grid_size - 2, -1, -1):
		positions.append(board_offset + Vector2(col * tile_size, (grid_size - 1) * tile_size))
	
	for row in range(grid_size - 2, 0, -1):
		positions.append(board_offset + Vector2(0, row * tile_size))
	
	return positions

func refresh() -> void:
	# Clear existing icons
	for child in get_children():
		child.queue_free()
	# Regenerate
	generate_icons()
	
