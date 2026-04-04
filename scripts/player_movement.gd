extends Sprite2D
class_name PlayerMovement

# --- Board settings ---
@export var tile_size: int = 32
@export var grid_size: int = 10
@export var board_start: Vector2 = Vector2(0, 0)

# --- Movement settings ---
var player_index: int = 0
var board_positions: Array[Vector2] = []
var move_queue: Array[Vector2] = []
var moving: bool = false
var passed_start: bool = false
@export var move_speed: float = 200.0

func _ready() -> void:
	# Don't auto-setup here, let the GameController call it
	pass

# --- Setup board ---
func set_board_positions() -> void:
	board_positions.clear()
	player_index = GameData.player_tile_index
	
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
		position = board_positions[player_index]
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
	passed_start = false

	for i in range(steps):
		var next_index = (player_index + 1) % get_total_tiles()

		# Check if we're crossing or landing on the start tile
		if next_index == 0 and player_index != 0:
			player_index = 0
			move_queue.append(board_positions[0])
			print("📍 Passing start tile — stopping here")
			passed_start = true
			break

		player_index = next_index
		move_queue.append(board_positions[player_index])
		#print("📍 Queuing move to position %d: %s" % [player_index, board_positions[player_index]])

	if not moving:
		_process_next_move()

func _process_next_move() -> void:
	if move_queue.is_empty():
		moving = false
		print("✅ Movement complete. Player at tile %d" % player_index)

		if passed_start:
			_on_passed_start()
		else:
			_on_landed(player_index)
		return

	moving = true
	var next_pos = move_queue.pop_front()
	var distance = position.distance_to(next_pos)
	var duration = distance / move_speed
	var tween = create_tween()
	tween.tween_property(self, "position", next_pos, duration)
	tween.tween_callback(Callable(self, "_process_next_move"))

func _on_passed_start() -> void:
	GameData.loop_count += 1
	SaveManager.save()
	
	GameData.loop_count += 1
	GameData.generate_board()
	get_tree().get_root().get_node("Game/GameBoard/BoardIcons").refresh()
	print("🏁 Passed start tile — choose a bonus!")
	get_tree().get_root().get_node("Game/StartTileUI").show_choices()

func _on_landed(index: int) -> void:
	GameData.player_tile_index = index
	var type = GameData.tile_types.get(index, "safe")
	print("Landed on %s tile" % type)
	
	match type:
		"combat":
			GameData.player_current_health = get_parent().get_node("PlayerStats").current_health
			print("💾 Saving health: %d" % GameData.player_current_health)
			GameData.player_tile_index = player_index
			GameData.current_enemy_data = _pick_enemy()
			get_tree().change_scene_to_file("res://scene/battle.tscn")
		"shop":
			pass
		"resource":
			_on_resource_landed()
		"safe":
			pass

func _on_resource_landed() -> void:
	var resource = ["gold", "wood", "stone"]
	var type = resource.pick_random()
	var base_amount = randi_range(5, 15)
	var amount = base_amount + (GameData.loop_count * 5)
	GameData.carried_resources[type] += amount
	print("💎 Gained %d %s! Total: %s" % [amount, type, GameData.carried_resources])
	GameData.emit_signal("resources_changed")

func _pick_enemy() -> Array[EnemyData]:
	var goblin = load("res://enemies/goblin.tres") as EnemyData
	return [goblin, goblin]
