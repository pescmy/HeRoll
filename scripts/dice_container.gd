class_name DiceContainer
extends Node2D

var dice_nodes := []
var dice_results := []
var rolling := false

@export var roll_duration: float = 1.0

func _ready():
	randomize()
	dice_nodes = [$Die1, $Die2]  # manually assign dice nodes

func roll_all_dice():
	if rolling:
		return
	rolling = true
	dice_results.clear()

	for die in dice_nodes:
		if not die.roll_finished.is_connected(_on_die_finished):
			die.roll_finished.connect(_on_die_finished)
		die.roll_die(roll_duration)

func _on_die_finished(result: int) -> void:
	dice_results.append(result)
	if dice_results.size() == dice_nodes.size():
		var total := 0
		for val in dice_results:
			total += val
		print("Dice results:", dice_results, "Total:", total)
		rolling = false

		for die in dice_nodes:
			if die.roll_finished.is_connected(_on_die_finished):
				die.roll_finished.disconnect(_on_die_finished)
