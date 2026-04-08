# shop_ui.gd
extends CanvasLayer
class_name ShopUI

signal shop_closed

const WEAPON_NAMES = ["Iron Sword", "Steel Blade", "War Axe", "Dagger", "Mace"]
const ARMOUR_NAMES = ["Leather Armour", "Chain Mail", "Iron Plate", "Hide Vest", "Scale Mail"]
const ACCESSORY_NAMES = ["Boots", "Ring of Power", "Amulet", "Bracers", "Lucky Charm"]

const RESOURCE_BASE_PRICES = {
	"gold": 10,
	"wood": 15,
	"stone": 15,
}

const RESOURCE_AMOUNTS = {
	"gold": 20,
	"wood": 25,
	"stone": 25,
}

const RESOURCE_ICONS = {
	"gold": "res://art/resources/coins.png",
	"wood": "res://art/resources/wood_pile.png",
	"stone": "res://art/resources/stone_pile.png",
}

var shop_item: Item = null

@onready var item_name_label: Label = $Panel/MarginContainer/VBoxContainer/ItemSection/ItemName
@onready var item_stats_label: Label = $Panel/MarginContainer/VBoxContainer/ItemSection/ItemStats
@onready var item_price_label: Label = $Panel/MarginContainer/VBoxContainer/ItemSection/ItemPrice
@onready var buy_item_button: Button = $Panel/MarginContainer/VBoxContainer/ItemSection/BuyItemButton
@onready var resources_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ResourcesSection
@onready var leave_button: Button = $Panel/MarginContainer/VBoxContainer/LeaveButton

func _ready() -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.5, 0.5, 0.5, 1.0)
	$Panel.add_theme_stylebox_override("panel", style)
	
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = Vector2(400, 350)
	$Panel.position = (viewport_size - panel_size) / 2
	$Panel.size = panel_size
	
	leave_button.pressed.connect(_on_leave_pressed)
	hide()

func open_shop() -> void:
	shop_item = _generate_item()
	_refresh_item()
	_refresh_resources()
	get_tree().get_root().get_node("Game/RollButton").disabled = true
	show()

# --- Item generation ---
func _generate_item() -> Item:
	var types = ["weapon", "armour", "accessory"]
	var type = types.pick_random()
	var item = Item.new()
	item.type = type

	var budget = 3 + (GameData.loop_count * 2)

	match type:
		"weapon":
			item.name = WEAPON_NAMES.pick_random()
			item.strength_bonus = budget
		"armour":
			item.name = ARMOUR_NAMES.pick_random()
			item.defense_bonus = randi_range(1, budget - 1)
			item.health_bonus = (budget - item.defense_bonus) * 5
		"accessory":
			item.name = ACCESSORY_NAMES.pick_random()
			var remaining = budget
			item.speed_bonus = randi_range(0, remaining)
			remaining -= item.speed_bonus
			item.defense_bonus = randi_range(0, remaining)
			remaining -= item.defense_bonus
			item.strength_bonus = remaining

	return item

# --- Pricing ---
func _get_item_price(item: Item) -> int:
	var total = item.strength_bonus + item.defense_bonus + item.speed_bonus
	total += int(item.health_bonus / 5.0)
	return total * 10

func _get_resource_price(resource_name: String) -> int:
	var base = RESOURCE_BASE_PRICES.get(resource_name, 10)
	return int(base * (1.0 + GameData.loop_count * 0.25))

# --- UI refresh ---
func _refresh_item() -> void:
	if shop_item == null:
		return
	var price = _get_item_price(shop_item)
	item_name_label.text = "%s (%s)" % [shop_item.name, shop_item.type]
	item_stats_label.text = _get_stat_summary(shop_item)
	item_price_label.text = "Cost: %d gold" % price
	buy_item_button.text = "Buy"
	buy_item_button.disabled = not _can_afford_gold(price)
	if not buy_item_button.pressed.is_connected(_on_buy_item_pressed):
		buy_item_button.pressed.connect(_on_buy_item_pressed)

func _refresh_resources() -> void:
	for child in resources_container.get_children():
		child.queue_free()

	for resource_name in RESOURCE_BASE_PRICES:
		var price = _get_resource_price(resource_name)
		var amount = RESOURCE_AMOUNTS[resource_name]

		var hbox = HBoxContainer.new()
		var label = Label.new()
		label.text = "Buy %d %s — %d gold" % [amount, resource_name, price]
		label.custom_minimum_size = Vector2(220, 0)

		var button = Button.new()
		button.text = "Buy"
		button.disabled = not _can_afford_gold(price)
		button.pressed.connect(_on_buy_resource_pressed.bind(resource_name, price, amount))

		hbox.add_child(label)
		hbox.add_child(button)
		resources_container.add_child(hbox)

# --- Button handlers ---
func _on_buy_item_pressed() -> void:
	var price = _get_item_price(shop_item)
	if not _can_afford_gold(price):
		return
	_spend_gold(price)
	GameData.add_to_inventory(shop_item.name, shop_item.type, 1, "res://art/resources/coins.png")
	buy_item_button.disabled = true
	buy_item_button.text = "Sold Out"
	print("🛒 Bought %s for %d gold" % [shop_item.name, price])

func _on_buy_resource_pressed(resource_name: String, price: int, amount: int) -> void:
	if not _can_afford_gold(price):
		return
	_spend_gold(price)
	GameData.add_to_inventory(resource_name, "resource", amount, RESOURCE_ICONS[resource_name])
	_refresh_resources()
	print("🛒 Bought %d %s for %d gold" % [amount, resource_name, price])

func _on_leave_pressed() -> void:
	get_tree().get_root().get_node("Game/RollButton").disabled = false
	hide()
	shop_closed.emit()

# --- Helpers ---
func _can_afford_gold(price: int) -> bool:
	for slot in GameData.inventory:
		if not slot.is_empty() and slot["name"] == "gold":
			return slot["amount"] >= price
	return false

func _spend_gold(amount: int) -> void:
	for slot in GameData.inventory:
		if not slot.is_empty() and slot["name"] == "gold":
			slot["amount"] -= amount
			GameData.inventory_changed.emit()
			return

func _get_stat_summary(item: Item) -> String:
	var parts = []
	if item.strength_bonus > 0: parts.append("+%d STR" % item.strength_bonus)
	if item.defense_bonus > 0: parts.append("+%d DEF" % item.defense_bonus)
	if item.speed_bonus > 0: parts.append("+%d SPD" % item.speed_bonus)
	if item.health_bonus > 0: parts.append("+%d HP" % item.health_bonus)
	return ", ".join(parts) if parts.size() > 0 else "No bonuses"
