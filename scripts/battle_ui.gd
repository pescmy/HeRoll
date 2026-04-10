# battle_ui.gd
extends Node
class_name BattleUI

@export var battle_controller: BattleController
@export var player: Node2D
@export var player_health_bar: ProgressBar
@export var enemy_health_bar: ProgressBar
@export var attack_button: Button

func _ready():
	setup_layout()
	battle_controller.battle_started.connect(_on_battle_started)
	battle_controller.battle_ended.connect(_on_battle_ended)
	battle_controller.player_attacked.connect(_on_player_attacked)
	battle_controller.enemy_attacked.connect(_on_enemy_attacked)
	battle_controller.target_changed.connect(_on_target_changed)
	attack_button.pressed.connect(_on_attack_pressed)

func setup_layout() -> void:
	# Player — left side
	player.position = Vector2(200, 350)
	
	# Player health bar — centred above player
	player_health_bar.position = Vector2(125, 290)
	player_health_bar.size = Vector2(150, 20)
	
	# Enemy health bar — centred above first enemy
	enemy_health_bar.position = Vector2(827, 290)
	enemy_health_bar.size = Vector2(150, 20)
	
	# Attack button — bottom centre
	attack_button.position = Vector2(501, 500)
	attack_button.size = Vector2(150, 40)

func _on_attack_pressed():
	if battle_controller.in_battle:
		battle_controller.player_attack()

func _on_battle_started():
	update_health_bars()
	attack_button.disabled = false

func _on_battle_ended(victory: bool):
	attack_button.disabled = true
	if victory:
		print("Victory!")
	else:
		print("Defeated!")

func _on_player_attacked(_damage: int):
	update_enemy_health_bar()

func _on_enemy_attacked(_damage: int):
	update_player_health_bar()
	attack_button.disabled = false

func _on_target_changed(enemy: Node):
	update_enemy_health_bar()

func update_health_bars() -> void:
	update_player_health_bar()
	update_enemy_health_bar()

func update_player_health_bar() -> void:
	player_health_bar.max_value = player.get_max_health()
	player_health_bar.value = player.get_current_health()

func update_enemy_health_bar() -> void:
	if battle_controller.current_target != null:
		enemy_health_bar.max_value = battle_controller.current_target.stats.max_health
		enemy_health_bar.value = battle_controller.current_target.stats.current_health

func _input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed:
		return
	if battle_controller.in_battle:
		if Input.is_action_just_pressed("attack"):
			battle_controller.player_attack()
