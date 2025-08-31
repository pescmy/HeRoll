extends Node

@export var player: Node2D             # Drag Player node here
@export var dice_instance: Node        # Drag Dice instance in scene
@export var start_tile: Vector2 = Vector2(13, 3)  # Tile coordinates for starting position
@export var tile_size: int = 32        # Size of each tile in pixels
@export var width: int = 10
@export var height: int = 10
@export var board_offset: Vector2 = Vector2(447, 108)  # Pixel offset of the board in the scene

var die1: Die
var die2: Die
var die3: Die

var perimeter_positions = []
var player_index = 0

var pending_rolls: int = 0
var roll_total: int = 0
var dice_results: Array = []

func _ready():
	if not player or not dice_instance:
		push_error("Player or Dice instance not assigned!")
		return

	# Find Die nodes under DiceContainer
	var dice_container = dice_instance.get_node("DiceContainer")
	die1 = dice_container.get_node("Die1")
	die2 = dice_container.get_node("Die2")
	die3 = dice_container.get_node("Die3")

	# Connect dice signals safely
	for die_name in ["Die1","Die2","Die3"]:
		var die_node = dice_container.get_node(die_name)
		if die_node:
			die_node.connect("roll_finished", Callable(self, "_on_die_finished"))
		else:
			print("Cannot find die:", die_name)

	# Build perimeter positions manually
	# Top row
	for x in range(width):
		perimeter_positions.append(Vector2(x * tile_size, 0))
	# Right column
	for y in range(1, height):
		perimeter_positions.append(Vector2((width - 1) * tile_size, y * tile_size))
	# Bottom row
	for x in range(width - 2, -1, -1):
		perimeter_positions.append(Vector2(x * tile_size, (height - 1) * tile_size))
	# Left column
	for y in range(height - 2, 0, -1):
		perimeter_positions.append(Vector2(0, y * tile_size))

	# Find start_tile index
	player_index = perimeter_positions.find(start_tile)
	if player_index == -1:
		player_index = 0
		print("Start tile not on perimeter, using first tile instead")

	# Place player at start with offset
	player.position = perimeter_positions[player_index] + board_offset
	print("Player start index:", player_index, "Position:", player.position)

func _on_die_finished(result: int) -> void:
	dice_results.append(result)
	roll_total += result
	pending_rolls = max(pending_rolls - 1, 0)  # prevent negative

	print("Die finished with:", result)
	print("Pending rolls:", pending_rolls, "Roll total so far:", roll_total)

	if pending_rolls == 0:
		print("All dice finished! Results:", dice_results, "Total:", roll_total)
		move_player(roll_total)
		dice_results.clear()
		roll_total = 0

func move_player(steps: int) -> void:
	player_index = (player_index + steps) % perimeter_positions.size()
	player.position = perimeter_positions[player_index] + board_offset
	print("Player moves to index:", player_index, "Position:", player.position)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		roll_dice()

func roll_dice() -> void:
	# Only roll dice if not already rolling
	if die1.rolling or die2.rolling or die3.rolling:
		print("Dice are already rolling!")
		return

	pending_rolls = 3
	roll_total = 0
	dice_results.clear()

	die1.roll_die()
	die2.roll_die()
	die3.roll_die()
