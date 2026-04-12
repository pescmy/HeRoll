extends Node

var player_tile_index: int = 0
var board_generated: bool = false

#36 board tiles, 4 corner tiles safe so 32 tiles
var tile_combat: int = 28
var tile_shop: int = 2
var tile_resource: int = 2
var tile_types: Dictionary = {}

var current_enemy_data: Array[EnemyData] = []
#var player_gold: int = 0
var player_current_health: int = -1
var player_max_health: int = 100
var inventory: Array = []
var inventory_size: int = 10
var loop_count: int = 0
var last_lost_resources: Array = []

var last_battle_stars: int = 0
var last_defeated_enemies: Array[EnemyData] = []

signal inventory_changed
signal loop_changed(new_count: int)

func _ready() -> void:
	init_inventory()
	SaveManager.load_save()
	inventory_size = 10 + TownData.get_upgrade_bonus("town_vault_storage")
	# DEBUG
	if inventory[0].is_empty():
		_debug_fill_inventory()
		inventory_changed.emit()
	if not board_generated:
		generate_board()
		board_generated = true

func init_inventory() -> void:
	inventory.clear()
	for i in range(inventory_size):
		inventory.append({})

# Call this manually in _ready() for testing, remove before release
func _debug_fill_inventory() -> void:
	inventory[0] = {"name": "gold", "type": "resource", "amount": 200, "icon": "res://art/resources/coins.png"}
	inventory[1] = {"name": "wood", "type": "resource", "amount": 200, "icon": "res://art/resources/wood_pile.png"}
	inventory[2] = {"name": "stone", "type": "resource", "amount": 200, "icon": "res://art/resources/stone_pile.png"}

func add_to_inventory(item_name: String, item_type: String, amount: int, icon_path: String) -> bool:
	# Check if resource already has a slot
	if item_type == "resource":
		for slot in inventory:
			if not slot.is_empty() and slot["name"] == item_name:
				slot["amount"] += amount
				inventory_changed.emit()
				return true
	
	# Find empty slot
	for i in range(inventory_size):
		if inventory[i].is_empty():
			inventory[i] = {
				"name": item_name,
				"type": item_type,
				"amount": amount,
				"icon": icon_path
			}
			inventory_changed.emit()
			return true
	
	# Inventory full
	print("❌ Inventory full!")
	return false

func remove_from_inventory(index: int) -> void:
	if index >= 0 and index < inventory_size:
		inventory[index] = {}
		inventory_changed.emit()

func reset_run() -> void:
	last_lost_resources = inventory.filter(func(slot): return not slot.is_empty())
	player_tile_index = 0
	player_current_health = -1
	loop_count = 0
	board_generated = false
	init_inventory()

func increment_loop() -> void:
	loop_count += 1
	loop_changed.emit(loop_count)

func generate_board() -> void:
	tile_types.clear()
	
	var corners = [0, 9, 18, 27]
	var pool = []
	
	for i in range(36):
		if not corners.has(i):
			pool.append(i)
	
	pool.shuffle()
	
	for i in corners:
		tile_types[i] = {"type": "safe", "stars": 0}
	
	for i in range(tile_combat):
		var stars = randi_range(1, 3)
		tile_types[pool[i]] = {"type": "combat", "stars": stars}
	
	for i in range(tile_combat, tile_combat + tile_shop):
		tile_types[pool[i]] = {"type": "shop", "stars": 0}
	
	for i in range(tile_combat + tile_shop, tile_combat + tile_shop + tile_resource):
		tile_types[pool[i]] = {"type": "resource", "stars": 0}

	for i in range(tile_combat + tile_shop + tile_resource, pool.size()):
		tile_types[pool[i]] = {"type": "safe", "stars": 0}
		
	board_generated = true
