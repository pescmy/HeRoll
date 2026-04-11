# battle_ui.gd
extends Node2D
class_name BattleUI

@export var battle_controller: BattleController
@export var player: Node2D
@export var player_health_bar: ProgressBar
@export var attack_button: Button

var enemy_health_bars: Array = []
var turn_order_label: Label = null
var player_stats_label: Label = null

var target_arrow: Label = null
var current_tinted_enemy = null

func _ready():
	set_process_unhandled_input(true)
	setup_layout()
	battle_controller.battle_started.connect(_on_battle_started)
	battle_controller.battle_ended.connect(_on_battle_ended)
	battle_controller.player_attacked.connect(_on_player_attacked)
	battle_controller.enemy_attacked.connect(_on_enemy_attacked)
	battle_controller.enemy_died.connect(_on_enemy_died)
	battle_controller.target_changed.connect(_on_target_changed)
	attack_button.pressed.connect(_on_attack_pressed)
	
	# Create target arrow
	target_arrow = Label.new()
	target_arrow.text = "▼"
	target_arrow.add_theme_color_override("font_color", Color.YELLOW)
	target_arrow.add_theme_font_size_override("font_size", 24)
	get_parent().call_deferred("add_child", target_arrow)

func setup_layout() -> void:
	player.position = Vector2(200, 350)
	
	# Player health bar
	player_health_bar.position = Vector2(125, 270)
	player_health_bar.size = Vector2(150, 20)
	player_health_bar.show_percentage = false
	
	# HP label on player bar
	var player_hp_label = Label.new()
	player_hp_label.name = "HPLabel"
	player_hp_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	player_hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	player_hp_label.add_theme_color_override("font_color", Color.WHITE)
	player_health_bar.add_child(player_hp_label)
	
	# Player stats panel
	player_stats_label = Label.new()
	player_stats_label.name = "PlayerStatsLabel"
	player_stats_label.position = Vector2(100, 300)
	player_stats_label.add_theme_color_override("font_color", Color.WHITE)
	get_parent().call_deferred("add_child", player_stats_label)
	
	# Turn order label
	turn_order_label = Label.new()
	turn_order_label.name = "TurnOrderLabel"
	turn_order_label.position = Vector2(20, 20)
	turn_order_label.add_theme_color_override("font_color", Color.YELLOW)
	get_parent().call_deferred("add_child", turn_order_label)
	
	# Attack button
	attack_button.position = Vector2(501, 500)
	attack_button.size = Vector2(150, 40)

func _on_battle_started():
	_create_enemy_health_bars()
	update_player_health_bar()
	_update_player_stats_label()
	_update_turn_order_label()
	_update_target_visuals()
	attack_button.disabled = false

func _create_enemy_health_bars() -> void:
	for entry in enemy_health_bars:
		if is_instance_valid(entry["bar"]):
			entry["bar"].queue_free()
		if is_instance_valid(entry.get("name_label")):
			entry["name_label"].queue_free()
		if is_instance_valid(entry.get("stats_label")):
			entry["stats_label"].queue_free()
	enemy_health_bars.clear()

	for enemy in battle_controller.enemies:
		# Health bar
		var bar = ProgressBar.new()
		bar.size = Vector2(100, 20)
		bar.position = enemy.position + Vector2(-50, -80)
		bar.max_value = enemy.stats.max_health
		bar.value = enemy.stats.current_health
		bar.show_percentage = false
		
		var hp_label = Label.new()
		hp_label.name = "HPLabel"
		hp_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hp_label.add_theme_color_override("font_color", Color.WHITE)
		hp_label.text = "%d/%d" % [enemy.stats.current_health, enemy.stats.max_health]
		bar.add_child(hp_label)
		get_parent().add_child(bar)

		# Enemy name label
		var name_label = Label.new()
		name_label.text = enemy.display_name
		name_label.position = enemy.position + Vector2(-50, -105)
		name_label.add_theme_color_override("font_color", Color.WHITE)
		get_parent().add_child(name_label)

		# Enemy stats label
		var stats_label = Label.new()
		stats_label.text = "STR:%d DEF:%d SPD:%d" % [enemy.stats.strength, enemy.stats.defense, enemy.stats.speed]
		stats_label.position = enemy.position + Vector2(-50, 50)
		stats_label.add_theme_font_size_override("font_size", 11)
		stats_label.add_theme_color_override("font_color", Color.LIGHT_GRAY)
		get_parent().add_child(stats_label)

		enemy_health_bars.append({
			"bar": bar,
			"enemy": enemy,
			"name_label": name_label,
			"stats_label": stats_label
		})

func _on_battle_ended(victory: bool):
	attack_button.disabled = true
	for entry in enemy_health_bars:
		if is_instance_valid(entry["bar"]):
			entry["bar"].queue_free()
		if is_instance_valid(entry.get("name_label")):
			entry["name_label"].queue_free()
		if is_instance_valid(entry.get("stats_label")):
			entry["stats_label"].queue_free()
	enemy_health_bars.clear()
	if turn_order_label:
		turn_order_label.text = ""
	if victory:
		print("Victory!")
	else:
		print("Defeated!")

func _on_attack_pressed():
	if battle_controller.in_battle:
		battle_controller.player_attack()

func _on_player_attacked(damage: int, blocked: int):
	update_enemy_health_bars()
	_update_turn_order_label()
	if battle_controller.current_target and is_instance_valid(battle_controller.current_target):
		var text = "-%d" % damage
		if blocked > 0:
			text += " (%d blocked)" % blocked
		_spawn_floating_text(text, battle_controller.current_target.position + Vector2(0, -100), Color.RED)

func _on_enemy_attacked(damage: int, blocked: int):
	update_player_health_bar()
	_update_player_stats_label()
	_update_turn_order_label()
	attack_button.disabled = false
	var text = "-%d" % damage
	if blocked > 0:
		text += " (%d blocked)" % blocked
	_spawn_floating_text(text, player.position + Vector2(0, -80), Color.ORANGE)

func _on_enemy_died(enemy: Node) -> void:
	for i in range(enemy_health_bars.size()):
		if enemy_health_bars[i]["enemy"] == enemy:
			if is_instance_valid(enemy_health_bars[i]["bar"]):
				enemy_health_bars[i]["bar"].queue_free()
			if is_instance_valid(enemy_health_bars[i].get("name_label")):
				enemy_health_bars[i]["name_label"].queue_free()
			if is_instance_valid(enemy_health_bars[i].get("stats_label")):
				enemy_health_bars[i]["stats_label"].queue_free()
			enemy_health_bars.remove_at(i)
			break

func _on_target_changed(_enemy: Node):
	update_enemy_health_bars()
	_update_turn_order_label()
	_update_target_visuals()

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

func _update_player_stats_label() -> void:
	if player_stats_label:
		player_stats_label.text = "STR:%d DEF:%d SPD:%d" % [
			player.stats.strength,
			player.stats.defense,
			player.stats.speed
		]

func _update_turn_order_label() -> void:
	if not turn_order_label:
		return
	var text = "Turn Order:\n"
	var turn_order = []
	turn_order.append({"name": "Player", "speed": player.stats.speed})
	for enemy in battle_controller.get_living_enemies():
		turn_order.append({"name": enemy.display_name, "speed": enemy.stats.speed})
	turn_order.sort_custom(func(a, b): return a["speed"] > b["speed"])
	for actor in turn_order:
		text += "%s (spd %d)\n" % [actor["name"], actor["speed"]]
	turn_order_label.text = text

func _spawn_floating_text(text: String, pos: Vector2, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 20)
	get_parent().add_child(label)
	var tween = label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", pos + Vector2(0, -60), 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.tween_callback(label.queue_free).set_delay(1.5)

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	if battle_controller.in_battle:
		if Input.is_action_just_pressed("attack"):
			battle_controller.player_attack()
		elif Input.is_action_just_pressed("ui_focus_next"): # Tab key
			_cycle_target()

func _cycle_target() -> void:
	var living = battle_controller.get_living_enemies()
	if living.is_empty():
		return
	if battle_controller.current_target == null:
		battle_controller.current_target = living[0]
	else:
		var idx = living.find(battle_controller.current_target)
		var next_idx = (idx + 1) % living.size()
		battle_controller.current_target = living[next_idx]
	battle_controller.target_changed.emit(battle_controller.current_target)
	_update_target_visuals()

func _update_target_visuals() -> void:
	# Remove tint from previous target
	if current_tinted_enemy and is_instance_valid(current_tinted_enemy):
		current_tinted_enemy.get_node("Sprite2D").modulate = Color.WHITE
	
	var target = battle_controller.current_target
	if target == null or not is_instance_valid(target):
		if target_arrow:
			target_arrow.visible = false
		return
	
	# Tint new target
	target.get_node("Sprite2D").modulate = Color(1.5, 0.5, 0.5)
	current_tinted_enemy = target
	
	# Move arrow above target
	if target_arrow:
		target_arrow.position = target.position + Vector2(-8, -120)
		target_arrow.visible = true
