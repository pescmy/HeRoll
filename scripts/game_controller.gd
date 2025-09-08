extends Node2D

@onready var board: TileMapLayer = $Board
@onready var player: Node2D = $Player
@onready var dice: DiceContainer = $DiceContainer

var current_tile: Vector2i = Vector2i(0, 0)

func _ready() -> void:
	if dice:
		dice.dice_rolled.connect(_on_dice_rolled)
	else:
		push_error("❌ DiceContainer not found")

	_move_player_to_tile(current_tile)

func _on_dice_rolled(total: int, results: Array) -> void:
	print("🎲 Rolled total:", total, "with breakdown:", results)
	current_tile.x += total   # simple test: move right
	_move_player_to_tile(current_tile)

func _move_player_to_tile(tile_coords: Vector2i) -> void:
	if not board:
		return
	var world_pos = board.map_to_local(tile_coords)
	player.position = world_pos
	print("👣 Player moved to:", tile_coords, "at", world_pos)
