extends Node2D

@onready var player = $Player
@onready var dice = $Dice

# Board configuration
const TILE_SIZE = 32
const GRID_SIZE = 10
const BOARD_START = Vector2(447, 108) # top-left corner of first tile

# Movement settings
var player_index: int = 0
var move_queue: Array = []
var moving: bool = false
var move_speed: float = 200.0 # pixels per second

func _ready() -> void:
	# Connect dice signals
	for die in dice.get_node("DiceContainer").get_children():
		if die.has_signal("roll_finished"):
			die.roll_finished.connect(_on_die_finished)

	print("GameController ready. Player at index %d" % player_index)
	player.position = get_tile_position(player_index)

# --- Dice handling ---
var pending_rolls: int = 0
var roll_total: int = 0

func roll_dice() -> void:
	# Reset state for a fresh roll
	pending_rolls = dice.get_node("DiceContainer").get_child_count()
	roll_total = 0

	for die in dice.get_node("DiceContainer").get_children():
		die.roll_die()

func _on_die_finished(result: int) -> void:
	print("Die finished with:%d" % result)
	pending_rolls -= 1
	roll_total += result
	print("Pending rolls:%d Roll total so far:%d" % [pending_rolls, roll_total])

	if pending_rolls <= 0:
		print("Final dice result total:%d" % roll_total)
		queue_player_movement(roll_total)
		roll_total = 0

# --- Movement handling ---
func queue_player_movement(steps: int) -> void:
	for i in range(steps):
		player_index = (player_index + 1) % get_total_tiles()
		move_queue.append(get_tile_position(player_index))

	if not moving:
		move_next_tile()

func move_next_tile() -> void:
	if move_queue.is_empty():
		moving = false
		return

	moving = true
	var next_pos = move_queue[0]
	move_queue.remove_at(0)
	var distance = player.position.distance_to(next_pos)
	var duration = distance / move_speed

	var tween = create_tween()
	tween.tween_property(player, "position", next_pos, duration)
	tween.tween_callback(Callable(self, "move_next_tile"))

# --- Board math ---
func get_tile_position(index: int) -> Vector2:
	var x: int
	var y: int

	if index < GRID_SIZE: # top row
		x = index
		y = 0
	elif index < GRID_SIZE * 2: # right column
		x = GRID_SIZE - 1
		y = index - GRID_SIZE
	elif index < GRID_SIZE * 3: # bottom row
		x = GRID_SIZE - 1 - (index - GRID_SIZE * 2)
		y = GRID_SIZE - 1
	else: # left column
		x = 0
		y = GRID_SIZE - 1 - (index - GRID_SIZE * 3)

	return BOARD_START + Vector2(x, y) * TILE_SIZE

func get_total_tiles() -> int:
	return GRID_SIZE * 4 - 4
