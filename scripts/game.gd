extends Node

func _ready() -> void:
	# Wait until all nodes are fully in the scene tree
	call_deferred("_assign_references_and_connect")

func _assign_references_and_connect() -> void:
	# Assign references to the singleton
	Data.player = get_node("Player")
	Data.board = get_node("Board")
	Data.dice = get_node("Dice")

	# Connect signals
	Data.dice.connect("dice_rolled", Callable(self, "_on_dice_rolled"))
	Data.player.connect("movement_finished", Callable(self, "_on_player_finished_moving"))
