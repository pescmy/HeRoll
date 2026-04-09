extends CanvasLayer

@onready var died_label: Label = $Panel/VBoxContainer/Died
@onready var resources_lost_label: Label = $Panel/VBoxContainer/ResourcesLost
@onready var try_again_button: Button = $Panel/VBoxContainer/TryAgainButton

func _ready() -> void:
	try_again_button.pressed.connect(_on_try_again_pressed)
	_show_lost_resources()

func _show_lost_resources() -> void:
	var lost = GameData.last_lost_resources
	if lost.is_empty():
		resources_lost_label.text = "No resources lost"
		resources_lost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		return
	
	var text = "Lost:\n"
	for slot in lost:
		text += "• %s x%d\n" % [slot["name"], slot["amount"]]
	resources_lost_label.text = text
	resources_lost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _on_try_again_pressed() -> void:
	SaveManager.save()
	get_tree().change_scene_to_file("res://scene/town.tscn")
