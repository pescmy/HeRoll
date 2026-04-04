extends CanvasLayer
class_name StartTileUI

@export var heal_amount: int = 20
@export var gold_amount: int = 50

signal choice_made

func _ready() -> void:
	hide()
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_choices() -> void:
	self.show()
	$Panel.mouse_filter = Control.MOUSE_FILTER_STOP

func _hide_ui() -> void:
	self.hide()
	$Panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_extract_pressed() -> void:
	print("Extracted! Gold banked: %d" % GameData.player_gold)
	_hide_ui()
	emit_signal("choice_made")

func _on_heal_pressed() -> void:
	var player_stats = get_tree().get_root().get_node("Game/Player/PlayerStats")
	var new_health = min(player_stats.current_health + heal_amount, player_stats.max_health)
	player_stats.current_health = new_health
	GameData.player_current_health = new_health
	print("Healed for %d! HP: %d/%d" % [heal_amount, new_health, player_stats.max_health])
	_hide_ui()
	choice_made.emit()

func _on_gold_pressed() -> void:
	GameData.player_gold += gold_amount
	print("Received %d gold! Total: %d" % [gold_amount, GameData.player_gold])
	_hide_ui()
	emit_signal("choice_made")
