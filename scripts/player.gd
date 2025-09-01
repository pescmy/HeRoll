extends Node2D

signal movement_finished

@export var speed := 0.2 # seconds per step
var board_positions: Array[Vector2] = []
var player_index := 0
var move_queue: Array[int] = []

func set_board_positions(positions: Array[Vector2]) -> void:
	board_positions = positions
	player_index = 0
	if not board_positions.is_empty():
		position = board_positions[0]
		print("Player start position: ", position) # ✅ Debug
	else:
		print("⚠️ No board positions received!")


# Called by GameController
func move_steps(steps: int) -> void:
	print("➡️ Moving steps: ", steps)
	if board_positions.is_empty():
		return
	move_queue.clear()

	for i in range(steps):
		player_index = (player_index + 1) % board_positions.size()
		move_queue.append(player_index)

	_process_next_move()

# Moves one step at a time with Tween
func _process_next_move() -> void:
	if move_queue.is_empty():
		emit_signal("movement_finished")
		return

	var next_index = move_queue.pop_front()
	var target_pos = board_positions[next_index]

	var tween = create_tween()
	tween.tween_property(self, "position", target_pos, speed)
	tween.tween_callback(Callable(self, "_process_next_move"))
