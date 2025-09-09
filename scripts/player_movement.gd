extends Sprite2D
class_name PlayerMovement

# --- Board settings ---
@export var tile_size: int = 32
@export var grid_size: int = 10
@export var board_start: Vector2 = Vector2(0, 0) # Will be calculated relative to parent position

# --- Movement settings ---
var player_index: int = 0
var board_positions: Array[Vector2] = []
var move_queue: Array[Vector2] = []
var moving: bool = false
@export var move_speed: float = 200.0 # pixels per second

func _ready() -> void:
	# Don't auto-setup here, let the GameController call it
	pass

# --- Setup board ---
func set_board_positions() -> void:
	board_positions.clear()
	player_index = 0
	
	# Calculate board start relative to the game board position
	# Adjust this offset to match your actual board position
	var board_offset = Vector2(0, 0) # Adjust these values as needed

	# Create a simple path around the board perimeter
	# Top row (left to right)
	for col in range(grid_size):
		board_positions.append(board_offset + Vector2(col * tile_size, 0))
	
	# Right column (top to bottom, excluding top-right corner)
	for row in range(1, grid_size):
		board_positions.append(board_offset + Vector2((grid_size - 1) * tile_size, row * tile_size))
	
	# Bottom row (right to left, excluding bottom-right corner)
	for col in range(grid_size - 2, -1, -1):
		board_positions.append(board_offset + Vector2(col * tile_size, (grid_size - 1) * tile_size))
	
	# Left column (bottom to top, excluding corners)
	for row in range(grid_size - 2, 0, -1):
		board_positions.append(board_offset + Vector2(0, row * tile_size))

	# Place player at first position
	if board_positions.size() > 0:
		position = board_positions[0]
		print("👤 Player starting at position: ", position)

func get_total_tiles() -> int:
	return grid_size * 4 - 4

# --- Movement ---
func move_steps(steps: int) -> void:
	if board_positions.is_empty():
		print("❌ Board positions not set!")
		set_board_positions()
		return

	move_queue.clear()

	
	for i in range(steps):
		player_index = (player_index + 1) % get_total_tiles()
		move_queue.append(board_positions[player_index])
		print("📍 Queuing move to position %d: %s" % [player_index, board_positions[player_index]])

	if not moving:
		_process_next_move()

func _process_next_move() -> void:
	if move_queue.is_empty():
		moving = false
		print("✅ Movement complete. Player at tile %d" % player_index)
		return

	moving = true
	var next_pos = move_queue.pop_front()
	var distance = position.distance_to(next_pos)
	var duration = distance / move_speed

	var tween = create_tween()
	tween.tween_property(self, "position", next_pos, duration)
	tween.tween_callback(Callable(self, "_process_next_move"))
