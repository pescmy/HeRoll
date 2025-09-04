extends Node2D

@onready var game_controller = $GameController
@onready var player = $Player
@onready var dice = $Dice
@onready var board = $Board

func _ready() -> void:
	print("Game scene ready!")
	# You can do any setup here if needed
	# For example: set starting player stats, equipment, etc.
	if player.has_node("PlayerStats"):
		var stats = player.get_node("PlayerStats")
		print("Player starting HP: %d" % stats.current_health)

func _process(delta: float) -> void:
	# Temporary test: press Enter to roll dice
	if Input.is_action_just_pressed("ui_accept"):
		if game_controller.has_method("roll_dice"):
			game_controller.roll_dice()
