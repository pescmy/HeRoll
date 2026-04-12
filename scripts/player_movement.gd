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
		#print("✅ Movement complete. Player at tile %d" % player_index)

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
	GameData.increment_loop()
	SaveManager.save()
	GameData.generate_board()
	get_tree().get_root().get_node("Game/GameBoard/BoardIcons").refresh()
	print("🏁 Passed start tile — choose a bonus!")
	get_tree().get_root().get_node("Game/StartTileUI").show_choices()

func _on_landed(index: int) -> void:
	GameData.player_tile_index = index
	var tile = GameData.tile_types.get(index, {"type": "safe", "stars": 0})
	var type = tile["type"]
	GameData.last_battle_stars = tile["stars"]
	print("Landed on %s tile (stars: %d)" % [type, tile["stars"]])
	
	match type:
		"combat":
			GameData.player_current_health = get_parent().get_node("PlayerStats").current_health
			print("💾 Saving health: %d" % GameData.player_current_health)
			GameData.player_tile_index = player_index
			GameData.current_enemy_data = _pick_enemy(tile["stars"])
			get_tree().change_scene_to_file("res://scene/battle.tscn")
		"shop":
			get_tree().get_root().get_node("Game/ShopUI").open_shop()
		"resource":
			_on_resource_landed()
		"safe":
			pass

func _on_resource_landed() -> void:
	var resources = ["gold", "wood", "stone"]
	var icons = {
		"gold": "res://art/resources/coins.png",
		"wood": "res://art/resources/wood_pile.png",
		"stone": "res://art/resources/stone_pile.png"
	}
	var type = resources.pick_random()
	var base_amount = randi_range(5, 15)
	var amount = base_amount + (GameData.loop_count * 5)
	var success = GameData.add_to_inventory(type, "resource", amount, icons[type])
	if success:
		print("💎 Gained %d %s!" % [amount, type])
		_spawn_floating_text("+%d %s" % [amount, type])
	else:
		_spawn_floating_text("Inventory full!")
		print("❌ Couldn't pick up %s — inventory full!" % type)

func _spawn_floating_text(text: String) -> void:
	var floating_text = preload("res://scene/floating_text.tscn").instantiate()
	floating_text.text = text
	
	var float_offset = Vector2(-30, -40)
	var total_tiles = get_total_tiles()
	
	if player_index >= grid_size and player_index < grid_size + grid_size - 1:
		float_offset = Vector2(40, -30)
	elif player_index >= grid_size + grid_size - 1 and player_index < total_tiles - (grid_size - 2):
		float_offset = Vector2(-30, 40)
	elif player_index >= total_tiles - (grid_size - 2):
		float_offset = Vector2(-80, -30)
	
	floating_text.position = position + float_offset
	get_parent().add_child(floating_text)

func _pick_enemy(stars: int) -> Array[EnemyData]:
	var enemy_pool = [
		load("res://enemies/goblin.tres") as EnemyData,
		load("res://enemies/slime.tres") as EnemyData,
		load("res://enemies/skeleton.tres") as EnemyData,
	]
	
	# Filter by loop unlock
	var available = enemy_pool.filter(func(e): return GameData.loop_count >= e.get_min_loop())
	
	# Budget per enemy slot based on stars + loop scaling
	var budget_per_enemy = float(stars) * 3.0 + (GameData.loop_count * 0.3)
	
	var result: Array[EnemyData] = []
	
	# Spawn exactly stars number of enemies
	for i in range(stars):
		var affordable = available.filter(func(e): return e.get_threat() <= budget_per_enemy)
		if affordable.is_empty():
			# Fallback to cheapest available
			var cheapest = available.reduce(func(a, b): return a if a.get_threat() < b.get_threat() else b)
			result.append(cheapest)
		else:
			result.append(affordable.pick_random())
	
	# Print encounter with numbered names
	var name_counts = {}
	for e in result:
		name_counts[e.name] = name_counts.get(e.name, 0) + 1
	var name_index = {}
	print("⚔️ %d★ encounter (budget per enemy %.1f): %d enemies" % [stars, budget_per_enemy, result.size()])
	for e in result:
		var display_name = e.name
		if name_counts[e.name] > 1:
			name_index[e.name] = name_index.get(e.name, 0) + 1
			display_name = "%s %d" % [e.name, name_index[e.name]]
		print("  - %s (threat %.1f)" % [display_name, e.get_threat()])

	return result
