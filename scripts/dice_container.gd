class_name DiceContainer
extends Node2D

signal dice_rolled(total: int, results: Array)

var dice: Array[Die] = []
var results: Array[int] = []
var remaining: int = 0

func _ready() -> void:
	dice.clear()
	for child in get_children():
		if child is Die:
			dice.append(child)

func roll_all_dice() -> void:
	if dice.is_empty():
		push_error("❌ No dice found in DiceContainer")
		return

	results.clear()
	remaining = dice.size()

	for die in dice:
		if not die.roll_finished.is_connected(_on_die_roll_finished):
			die.roll_finished.connect(_on_die_roll_finished)
		die.roll_die()

func _on_die_roll_finished(result: int) -> void:
	results.append(result)
	remaining -= 1

	if remaining <= 0:
		var total: int = results.reduce(func(a, b): return a + b, 0)
		emit_signal("dice_rolled", total, results)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Roll Dice"): # R key (set in InputMap)
		roll_all_dice()
		print("🎲 R triggered a roll")
