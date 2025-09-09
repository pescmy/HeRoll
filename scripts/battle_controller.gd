# battle_controller.gd
extends Node
class_name BattleController

@export var player: Node2D
@export var enemy_scene: PackedScene

var current_enemy: Node = null
var enemies_defeated: int = 0
var in_battle: bool = false

signal battle_started(enemy)
signal battle_ended(victory: bool)

func start_battle():
	if in_battle:
		return
	in_battle = true

	# Instantiate an enemy
	current_enemy = enemy_scene.instantiate()
	add_child(current_enemy)
	current_enemy.position = Vector2(400, 300) # example spawn position

	emit_signal("battle_started", current_enemy)
	print("Battle started against %s" % current_enemy.name)

func player_attack(damage: int):
	if not in_battle or current_enemy == null:
		return

	current_enemy.take_damage(damage)

	if current_enemy.is_dead():
		end_battle(true)
	else:
		enemy_turn()

func enemy_turn():
	if not in_battle or current_enemy == null:
		return

	var damage = current_enemy.get_attack_damage()
	player.take_damage(damage)
	print("Enemy attacks for %d damage" % damage)

func end_battle(victory: bool):
	if current_enemy != null:
		current_enemy.queue_free()
		current_enemy = null

	in_battle = false
	if victory:
		enemies_defeated += 1
	print("Battle ended. Victory: %s" % victory)
	emit_signal("battle_ended", victory)
