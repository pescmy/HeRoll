# battle_ui.gd
extends Node2D
class_name BattleUI

@export var battle_controller: BattleController
@export var player: Node2D
@export var player_health_bar: ProgressBar
@export var attack_button: Button

var enemy_health_bars: Array = []

func _ready():
	battle_controller.battle_started.connect(_on_battle_started)
	battle_controller.battle_ended.connect(_on_battle_ended)
	battle_controller.player_attacked.connect(_on_player_attacked)
	battle_controller.enemy_attacked.connect(_on_enemy_attacked)
	battle_controller.enemy_died.connect(_on_enemy_died)
	battle_controller.target_changed.connect(_on_target_changed)
	attack_button.pressed.connect(_on_attack_pressed)
	set_process_input(true)

func setup_layout() -> void:
	player.position = Vector2(200, 350)
	
	# Player health bar — same height as enemy bars
	player_health_bar.position = Vector2(125, 270)
	player_health_bar.size = Vector2(150, 20)
	player_health_bar.show_percentage = false
	
	# Add label to player health bar
	var player_hp_label = Label.new()
	player_hp_label.name = "HPLabel"
	player_hp_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	player_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	player_hp_label.add_theme_color_override("font_color", Color.WHITE)
	player_health_bar.add_child(player_hp_label)
	
	attack_button.position = Vector2(501, 500)
	attack_button.size = Vector2(150, 40)

func _on_battle_started():
	_create_enemy_health_bars()
	update_player_health_bar()
	attack_button.disabled = false

func _create_enemy_health_bars() -> void:
	for bar in enemy_health_bars:
		if is_instance_valid(bar):
			bar.queue_free()
	enemy_health_bars.clear()

	for enemy in battle_controller.enemies:
		var bar = ProgressBar.new()
		bar.size = Vector2(100, 20)
		bar.position = enemy.position + Vector2(-50, -80)
		bar.max_value = enemy.stats.max_health
		bar.value = enemy.stats.current_health
		bar.show_percentage = false
		
		# Add label to enemy health bar
		var hp_label = Label.new()
		hp_label.name = "HPLabel"
		hp_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hp_label.add_theme_color_override("font_color", Color.WHITE)
		hp_label.text = "%d/%d" % [enemy.stats.current_health, enemy.stats.max_health]
		bar.add_child(hp_label)
		
		get_parent().add_child(bar)
		enemy_health_bars.append({"bar": bar, "enemy": enemy})

	for enemy in battle_controller.enemies:
		var bar = ProgressBar.new()
		bar.size = Vector2(100, 16)
		bar.position = enemy.position + Vector2(-50, -80)
		bar.max_value = enemy.stats.max_health
		bar.value = enemy.stats.current_health
		bar.show_percentage = false
		get_parent().add_child(bar)
		enemy_health_bars.append({"bar": bar, "enemy": enemy})

func _on_battle_ended(victory: bool):
	attack_button.disabled = true
	for entry in enemy_health_bars:
		if is_instance_valid(entry["bar"]):
			entry["bar"].queue_free()
	enemy_health_bars.clear()
	if victory:
		print("Victory!")
	else:
		print("Defeated!")

func _on_attack_pressed():
	if battle_controller.in_battle:
		battle_controller.player_attack()

func _on_player_attacked(_damage: int):
	update_enemy_health_bars()

func _on_enemy_attacked(_damage: int):
	update_player_health_bar()
	attack_button.disabled = false

func _on_enemy_died(enemy: Node) -> void:
	# Remove the health bar for the dead enemy
	for i in range(enemy_health_bars.size()):
		if enemy_health_bars[i]["enemy"] == enemy:
			if is_instance_valid(enemy_health_bars[i]["bar"]):
				enemy_health_bars[i]["bar"].queue_free()
			enemy_health_bars.remove_at(i)
			break

func _on_target_changed(_enemy: Node):
	update_enemy_health_bars()

func update_player_health_bar() -> void:
	player_health_bar.max_value = player.get_max_health()
	player_health_bar.value = player.get_current_health()
	var label = player_health_bar.get_node_or_null("HPLabel")
	if label:
		label.text = "%d/%d" % [player.get_current_health(), player.get_max_health()]

func update_enemy_health_bars() -> void:
	for entry in enemy_health_bars:
		if is_instance_valid(entry["enemy"]) and is_instance_valid(entry["bar"]):
			entry["bar"].value = entry["enemy"].stats.current_health
			var label = entry["bar"].get_node_or_null("HPLabel")
			if label:
				label.text = "%d/%d" % [entry["enemy"].stats.current_health, entry["enemy"].stats.max_health]
