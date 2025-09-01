extends Node2D
class_name PlayerMovement

# --- Board settings ---
@export var tile_size: int = 32
@export var grid_size: int = 10
@export var board_start: Vector2 = Vector2(0, 0) # top-left corner

# --- Movement settings ---
var player_index: int = 0
var board_positions: Array[Vector2] = []
var move_queue: Array[Vector2] = []
var moving: bool = false
@export var move_speed: float = 200.0 # pixels per second



# --- Setup board ---
func set_board_positions() -> void:
	board_positions.clear()
	player_index = 0

	# Top row
	for col in range(grid_size):
		board_positions.append(board_start + Vector2(col * tile_size, 0))
	# Right column (excluding first top-right corner)
	for row in range(1, grid_size):
		board_positions.append(board_start + Vector2((grid_size - 1) * tile_size, row * tile_size))
	# Bottom row (excluding bottom-right corner, right-to-left)
	for col in range(grid_size - 2, -1, -1):
		board_positions.append(board_start + Vector2(col * tile_size, (grid_size - 1) * tile_size))
	# Left column (excluding top-left and bottom-left corners, bottom-to-top)
	for row in range(grid_size - 2, 0, -1):
		board_positions.append(board_start + Vector2(0, row * tile_size))

	# Place player at first tile
	if board_positions.size() > 0:
		position = board_positions[0]


func get_tile_position(index: int) -> Vector2:
	var x: int
	var y: int

	if index < grid_size: # top row
		x = index
		y = 0
	elif index < grid_size * 2: # right column
		x = grid_size - 1
		y = index - grid_size
	elif index < grid_size * 3: # bottom row
		x = grid_size - 1 - (index - grid_size * 2)
		y = grid_size - 1
	else: # left column
		x = 0
		y = grid_size - 1 - (index - grid_size * 3)

	return board_start + Vector2(x, y) * tile_size

func get_total_tiles() -> int:
	return grid_size * 4 - 4

# --- Movement ---
func move_steps(steps: int) -> void:
	if board_positions.is_empty():
		print("Board positions not set!")
		return

	move_queue.clear()
	for i in range(steps):
		player_index = (player_index + 1) % get_total_tiles()
		move_queue.append(board_positions[player_index])

	if not moving:
		_process_next_move()

func _process_next_move() -> void:
	if move_queue.is_empty():
		moving = false
		return

	moving = true
	var next_pos = move_queue.pop_front()
	var distance = position.distance_to(next_pos)
	var duration = distance / move_speed

	var tween = create_tween()
	tween.tween_property(self, "position", next_pos, duration)
	tween.tween_callback(Callable(self, "_process_next_move"))
