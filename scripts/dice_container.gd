class_name DiceContainer
extends Node2D

signal dice_rolled(total: int, results: Array)

# Array of Die nodes
var dice: Array[Die] = []
var results: Array[int] = []
var remaining: int = 0

func _ready() -> void:
	# Collect all Die children automatically
	dice.clear()
	for child in get_children():
		if child is Die:
			dice.append(child)

func roll_all_dice() -> void:
	if dice.size() == 0:
		push_error("❌ No dice found in DiceContainer")
		return

	results.clear()
	remaining = dice.size()

	for die in dice:
		# Create callable to this method
		var c: Callable = Callable(self, "_on_die_roll_finished")
		
		# Disconnect previous connections if connected
		if die.is_connected("roll_finished", c):
			die.disconnect("roll_finished", c)

		# Connect signal
		die.roll_finished.connect(c)
		die.roll_die()

func _on_die_roll_finished(result: int) -> void:
	results.append(result)
	remaining -= 1
	if remaining <= 0:
		# Sum all results
		var total: int = results.reduce(func(a, b): return a + b)
		emit_signal("dice_rolled", total, results)
