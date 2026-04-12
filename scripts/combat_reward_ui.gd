# combat_reward_ui.gd
extends CanvasLayer
class_name CombatRewardUI

signal reward_claimed

var reward_calc: CombatReward = CombatReward.new()
var gold_reward: int = 0
var dropped_items: Array[Item] = []
var selected_item: Item = null

@onready var gold_label: Label = $Panel/MarginContainer/VBoxContainer/GoldLabel
@onready var items_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ItemsContainer
@onready var continue_button: Button = $Panel/MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	hide()

func show_rewards() -> void:
	if GameData.last_defeated_enemies.is_empty():
		return
	
	gold_reward = reward_calc.calculate_gold(GameData.last_defeated_enemies, GameData.last_battle_stars)
	dropped_items = reward_calc.roll_drops(GameData.last_defeated_enemies)
	
	gold_label.text = "Gold earned: %d" % gold_reward
	
	# Clear previous items
	for child in items_container.get_children():
		child.queue_free()
	
	if dropped_items.is_empty():
		var no_drop = Label.new()
		no_drop.text = "No items dropped"
		items_container.add_child(no_drop)
	else:
		var title = Label.new()
		title.text = "Choose an item (or none):"
		items_container.add_child(title)
		
		for item in dropped_items:
			var hbox = HBoxContainer.new()
			var label = Label.new()
			label.text = "%s (%s) — %s" % [item.name, item.type, _get_stat_summary(item)]
			label.custom_minimum_size = Vector2(280, 0)
			var button = Button.new()
			button.text = "Take"
			button.pressed.connect(_on_take_item_pressed.bind(item, button))
			hbox.add_child(label)
			hbox.add_child(button)
			items_container.add_child(hbox)
	
	show()

func _on_take_item_pressed(item: Item, button: Button) -> void:
	selected_item = item
	# Disable all other take buttons
	for child in items_container.get_children():
		if child is HBoxContainer:
			var btn = child.get_node_or_null("Button") 
			if btn and btn != button:
				btn.disabled = true
	button.text = "✓ Taken"
	button.disabled = true
	print("🎁 Selected item: %s" % item.name)

func _on_continue_pressed() -> void:
	# Add gold to inventory
	GameData.add_to_inventory("gold", "resource", gold_reward, "res://art/resources/coins.png")
	print("💰 Gained %d gold from combat!" % gold_reward)
	
	# Add selected item if any
	if selected_item != null:
		GameData.add_to_inventory(selected_item.name, selected_item.type, 1, "res://art/resources/coins.png")
		print("🎁 Added %s to inventory!" % selected_item.name)
	
	# Clear reward data
	GameData.last_defeated_enemies.clear()
	GameData.last_battle_stars = 0
	selected_item = null
	
	hide()
	reward_claimed.emit()

func _get_stat_summary(item: Item) -> String:
	var parts = []
	if item.strength_bonus > 0: parts.append("+%d STR" % item.strength_bonus)
	if item.defense_bonus > 0: parts.append("+%d DEF" % item.defense_bonus)
	if item.speed_bonus > 0: parts.append("+%d SPD" % item.speed_bonus)
	if item.health_bonus > 0: parts.append("+%d HP" % item.health_bonus)
	return ", ".join(parts) if parts.size() > 0 else "No bonuses"
