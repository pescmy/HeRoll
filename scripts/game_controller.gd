class_name GameController
extends Node

@onready var player: Node2D = $Player
@onready var board: TileMapLayer = $GameBoard/Board
@onready var dice_container: DiceContainer = $DiceContainer
@onready var roll_button: Button = $RollButton

var current_tile: Vector2i = Vector2i.ZERO

func _ready() -> void:
	if not board:
		push_error("❌ Board (TileMapLayer) not found, check scene tree naming!")
		return

	# 🔎 Find the first tile actually used in the TileMapLayer
	var used_cells = board.get_used_cells()
	if used_cells.size() > 0:
		current_tile = used_cells[0]   # take the first painted tile
	else:
		push_error("⚠️ No tiles found in Board, defaulting to (0,0)")
		current_tile = Vector2i(0, 0)

	# Hook up signals
	roll_button.pressed.connect(_on_roll_button_pressed)
	dice_container.dice_rolled.connect(_on_dice_rolled)

	# Place player on starting tile
	_move_player_to_tile(current_tile)

func _on_roll_button_pressed() -> void:
	dice_container.roll_all_dice()

func _on_dice_rolled(total: int, results: Array) -> void:
	print("🎲 Rolled: %s (total %d)" % [results, total])
	current_tile.x += total   # test: move right across the board
	_move_player_to_tile(current_tile)

func _move_player_to_tile(tile_coords: Vector2i) -> void:
	if not board:
		push_error("❌ Board not found")
		return

	var world_pos: Vector2 = board.map_to_local(tile_coords)
	player.position = world_pos
	print("👣 Player moved to:", tile_coords, "at", world_pos)
