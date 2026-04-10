extends Node2D

@onready var game_controller: Node2D = $GameController
@onready var player: Node2D = $Player
@onready var dice = $DiceContainer
@onready var board = $GameBoard

var board_generated: bool = false

func _ready() -> void:
	print("Game scene ready!")
	# DEBUG - remove before release
	if GameData.inventory[0].is_empty():
		GameData._debug_fill_inventory()
		GameData.inventory_changed.emit()
	if player.has_node("PlayerStats"):
		var stats = player.get_node("PlayerStats")
		print("Player starting HP: %d" % stats.current_health)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		if game_controller.has_method("roll_dice"):
			game_controller.roll_dice()
