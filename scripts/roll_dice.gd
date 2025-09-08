extends Button

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	var dice_container = get_parent().get_node("DiceContainer")
	if dice_container:
		dice_container.roll_all_dice()
