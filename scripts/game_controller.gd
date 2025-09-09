class_name GameController
extends Node

@onready var player: Node2D = get_node("../Player")
@onready var player_movement: PlayerMovement = get_node("../Player/PlayerMovement")
@onready var board: TileMapLayer = get_node("../GameBoard/Board")
@onready var dice_container: DiceContainer = get_node("../DiceContainer")
@onready var roll_button: Button = get_node("../RollButton")

func _ready() -> void:
	if not board:
		push_error("❌ Board (TileMapLayer) not found, check scene tree naming!")
		return

	# Initialize the player movement system
	if player_movement:
		player_movement.set_board_positions()
		print("✅ Player positioned at starting tile")
	else:
		push_error("❌ PlayerMovement component not found!")

	# Hook up signals
	roll_button.pressed.connect(_on_roll_button_pressed)
	dice_container.dice_rolled.connect(_on_dice_rolled)

func _on_roll_button_pressed() -> void:
	dice_container.roll_all_dice()

func _on_dice_rolled(total: int, results: Array) -> void:
	print("🎲 Rolled: %s (total %d)" % [results, total])
	
	# Use the PlayerMovement system instead of manual tile positioning
	if player_movement:
		player_movement.move_steps(total)
	else:
		push_error("❌ PlayerMovement not found, cannot move player")
