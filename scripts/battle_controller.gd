# battle_controller.gd
extends Node
class_name BattleController

@export var player: Node2D

var enemies: Array = []
var current_target: Node = null
var in_battle: bool = false

signal battle_started
signal battle_ended(victory: bool)
signal player_attacked(damage: int, blocked: int)
signal enemy_attacked(damage: int, blocked: int)
signal enemy_died(enemy: Node)
signal target_changed(enemy: Node)

func _ready():
	call_deferred("start_battle")

func start_battle():
	if in_battle:
		return
	
	if GameData.current_enemy_data.is_empty():
		push_error("❌ No enemy data — redirecting to board")
		get_tree().change_scene_to_file("res://scene/game.tscn")
		return
		
	in_battle = true
	
	var enemy_count = GameData.current_enemy_data.size()
	var enemy_area_start = 550
	var enemy_area_width = 500
	var spacing = enemy_area_width / float(enemy_count + 1)
	
	var name_counts = {}
	for data in GameData.current_enemy_data:
		name_counts[data.name] = name_counts.get(data.name, 0) + 1
	
	var name_index = {}
	for i in range(enemy_count):
		var enemy = load("res://scene/enemy.tscn").instantiate()
		enemy.data = GameData.current_enemy_data[i]
		var base_name = GameData.current_enemy_data[i].name
		
		if name_counts[base_name] > 1:
			name_index[base_name] = name_index.get(base_name, 0) + 1
			enemy.name = "%s%d" % [base_name, name_index[base_name]]
			enemy.display_name = "%s %d" % [base_name, name_index[base_name]]
		else:
			enemy.name = base_name
			enemy.display_name = base_name
		
		add_child(enemy)
		enemy.position = Vector2(enemy_area_start + spacing * (i + 1), 350)
		enemies.append(enemy)
		
		enemy.clicked.connect(_on_enemy_clicked)
		
		print("📊 %s stats: HP %d/%d, Str %d, Def %d, Spd %d" % [
			enemy.display_name,
			enemy.stats.current_health,
			enemy.stats.max_health,
			enemy.stats.strength,
			enemy.stats.defense,
			enemy.stats.speed
		])
	
	current_target = enemies[0]
	battle_started.emit()
	target_changed.emit(current_target)
	print("Battle started with %d enemies" % enemies.size())

func _on_enemy_clicked(enemy: Node) -> void:
	if not in_battle:
		return
	current_target = enemy
	target_changed.emit(current_target)
	print("🎯 Target changed to: %s" % current_target.display_name)

func player_attack() -> void:
	if not in_battle or current_target == null:
		return
	
	var turn_order = []
	turn_order.append({"type": "player", "speed": player.stats.speed})
	for enemy in get_living_enemies():
		turn_order.append({"type": "enemy", "enemy": enemy, "speed": enemy.stats.speed})
	
	turn_order.sort_custom(func(a, b): return a["speed"] > b["speed"])
	
	print("--- Turn Order ---")
	for actor in turn_order:
		if actor["type"] == "player":
			print("  Player (spd %d)" % actor["speed"])
		else:
			print("  %s (spd %d)" % [actor["enemy"].display_name, actor["speed"]])
	print("------------------")
	
	for actor in turn_order:
		if actor["type"] == "player":
			_execute_player_attack()
			if not in_battle:
				return
		else:
			var enemy = actor["enemy"]
			if is_instance_valid(enemy) and not enemy.is_dead():
				_execute_enemy_attack(enemy)
				if not in_battle:
					return

func _execute_player_attack() -> void:
	if current_target == null or not is_instance_valid(current_target):
		return
	var raw = player.get_attack_damage()
	var actual = current_target.take_damage(raw)
	var blocked = raw - actual
	print("⚔️ Player hits %s for %d damage (%d blocked)" % [current_target.display_name, actual, blocked])
	player_attacked.emit(actual, blocked)

	if current_target.is_dead():
		print("💀 %s has been defeated!" % current_target.display_name)
		enemy_died.emit(current_target)
		enemies.erase(current_target)
		current_target.queue_free()
		current_target = null
		if enemies.is_empty():
			end_battle(true)
			return
		else:
			current_target = enemies[0]
			print("🎯 New target: %s" % current_target.display_name)
			target_changed.emit(current_target)

func _execute_enemy_attack(enemy: Node) -> void:
	var raw = enemy.get_attack_damage()
	var actual = player.take_damage(raw)
	var blocked = raw - actual
	print("🗡️ %s hits player for %d damage (%d blocked)" % [enemy.display_name, actual, blocked])
	enemy_attacked.emit(actual, blocked)
	if player.is_dead():
		print("💀 Player has been defeated!")
		end_battle(false)

func get_living_enemies() -> Array:
	return enemies.filter(func(e): return not e.is_dead())

func end_battle(victory: bool) -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemies.clear()
	current_target = null
	in_battle = false
	
	GameData.player_current_health = player.get_current_health()
	print("💾 Saving health after battle: %d" % GameData.player_current_health)
	SaveManager.save()
	
	battle_ended.emit(victory)
	
	await get_tree().create_timer(1.5).timeout
	
	if victory:
		get_tree().change_scene_to_file("res://scene/game.tscn")
	else:
		GameData.reset_run()
		SaveManager.save()
		get_tree().change_scene_to_file("res://scene/death_screen.tscn")
