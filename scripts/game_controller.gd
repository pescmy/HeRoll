extends Node

@onready var player_movement = $Player/PlayerMovement
@onready var dice = $Dice

var pending_rolls: int = 0
var roll_total: int = 0

func _ready():
	# Set up the board
	player_movement.set_board_positions()

	# Connect dice signals
	for die in dice.get_node("DiceContainer").get_children():
		if die.has_signal("roll_finished"):
			die.roll_finished.connect(_on_die_finished)

func roll_dice(num_dice: int = 2) -> void:
	pending_rolls = num_dice
	roll_total = 0

	for die in dice.get_node("DiceContainer").get_children():
		die.roll_die()

func _on_die_finished(result: int) -> void:
	pending_rolls -= 1
	roll_total += result

	if pending_rolls <= 0:
		print("Total dice:", roll_total)
		player_movement.move_steps(roll_total)
		roll_total = 0
