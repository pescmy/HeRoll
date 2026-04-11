# battle_controller.gd
extends Node
class_name BattleController

@export var player: Node2D

var enemies: Array = []
var current_target: Node = null
var in_battle: bool = false

signal battle_started
signal battle_ended(victory: bool)
signal player_attacked(damage: int)
signal enemy_attacked(damage: int)
signal enemy_died(enemy: Node)
signal target_changed(enemy: Node)

func _ready():
	call_deferred("start_battle")

#func _process(_delta: float) -> void:
	#if in_battle and Input.is_action_just_pressed("attack"):
		#player_attack()

func start_battle():
	if in_battle:
		return
	in_battle = true

	var enemy_count = GameData.current_enemy_data.size()
	var viewport_width = 1152
	var enemy_area_start = 550
	var enemy_area_width = 500
	var spacing = enemy_area_width / (enemy_count + 1)

	for i in range(enemy_count):
		var enemy = load("res://scene/enemy.tscn").instantiate()
		enemy.data = GameData.current_enemy_data[i]
		add_child(enemy)
		enemy.position = Vector2(enemy_area_start + spacing * (i + 1), 350)
		enemies.append(enemy)

	current_target = enemies[0]
	battle_started.emit()
	target_changed.emit(current_target)
	print("Battle started with %d enemies" % enemies.size())

func player_attack():
	if not in_battle or current_target == null:
		return

	var damage = player.get_attack_damage()
	current_target.take_damage(damage)
	emit_signal("player_attacked", damage)
	print("Player attacks %s for %d damage" % [current_target.name, damage])

	if current_target.is_dead():
		emit_signal("enemy_died", current_target)
		enemies.erase(current_target)
		current_target.queue_free()
		current_target = null

		if enemies.is_empty():
			end_battle(true)
			return
		else:
			current_target = enemies[0]
			emit_signal("target_changed", current_target)

	enemy_turn()

func get_living_enemies() -> Array:
	return enemies.filter(func(e): return not e.is_dead())

func enemy_turn():
	if not in_battle:
		return

	var living = get_living_enemies()
	living.sort_custom(func(a, b): return a.stats.speed > b.stats.speed)

	for enemy in living:
		var damage = enemy.get_attack_damage()
		player.take_damage(damage)
		emit_signal("enemy_attacked", damage)
		print("%s attacks for %d damage" % [enemy.name, damage])

		if player.is_dead():
			end_battle(false)
			return

func end_battle(victory: bool) -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	enemies.clear()
	current_target = null
	
	GameData.player_current_health = player.get_current_health()
	SaveManager.save()
	
	in_battle = false
	
		# Save player health before leaving battle scene
	GameData.player_current_health = player.get_current_health()
	print("💾 Saving health after battle: %d" % GameData.player_current_health)
	
	emit_signal("battle_ended", victory)
	
	await get_tree().create_timer(1.5).timeout
	
	if victory:
		get_tree().change_scene_to_file("res://scene/game.tscn")
	else:
		GameData.reset_run()
		SaveManager.save()
		#await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://scene/death_screen.tscn")
