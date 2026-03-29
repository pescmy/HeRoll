# battle_controller.gd
extends Node
class_name BattleController

@export var player: Node2D
@export var enemy_scene: PackedScene
@export var enemy_data: EnemyData

@export var player_health_bar: ProgressBar
@export var enemy_health_bar: ProgressBar

@export var attack_button: Button

var current_enemy: Node = null
var in_battle: bool = false

signal battle_started(enemy: Node)
signal battle_ended(victory: bool)

func _ready():
	attack_button.pressed.connect(_on_attack_pressed)
	call_deferred("start_battle")

func _on_attack_pressed():
	if in_battle:
		player_attack()

func start_battle():
	if in_battle:
		return
	in_battle = true

	# Create the enemy
	current_enemy = enemy_scene.instantiate()
	current_enemy.data = enemy_data
	add_child(current_enemy)

	update_health_bars()

	emit_signal("battle_started", current_enemy)
	print("Battle started against: %s" % current_enemy.name)

func player_attack():
	if not in_battle or current_enemy == null:
		return

	var damage = player.get_attack_damage()
	print("Player attacks for %d damage" % damage)
	current_enemy.take_damage(damage)

	update_health_bars()

	if current_enemy.is_dead():
		end_battle(true)
	else:
		enemy_turn()

func enemy_turn():
	if not in_battle or current_enemy == null:
		return

	attack_button.disabled = true

	if current_enemy.has_method("get_attack_damage") and player.has_method("take_damage"):
		var damage = current_enemy.get_attack_damage()
		print("Enemy attacks for %d damage" % damage)
		player.take_damage(damage)
	
	update_health_bars()
	
	if player.is_dead():
		end_battle(false)
	else:
		attack_button.disabled = false

func end_battle(victory: bool):
	if current_enemy != null:
		current_enemy.queue_free()
		current_enemy = null

	in_battle = false
	attack_button.disabled = true

	if victory:
		print("Battle ended. Victory!")
	else:
		print("Battle ended. Defeated!")

	emit_signal("battle_ended", victory)

func update_health_bars() -> void:
	player_health_bar.max_value = player.get_max_health()
	player_health_bar.value = player.get_current_health()
	enemy_health_bar.max_value = current_enemy.stats.max_health
	enemy_health_bar.value = current_enemy.stats.current_health
