extends Node

var player_tile_index: int = 0
var board_generated: bool = false

var tile_combat: int = 20
var tile_shop: int = 2
var tile_resource: int = 10
var tile_types: Dictionary = {}

var current_enemy_data: Array[EnemyData] = []

var player_gold: int = 0
var player_current_health: int = -1
var player_max_health: int = 100

var inventory: Array = []
var inventory_size: int = 10

var loop_count: int = 0

signal inventory_changed

func _ready() -> void:
	SaveManager.load_save()
	init_inventory()
	if not board_generated:
		generate_board()
		board_generated = true

func init_inventory() -> void:
	inventory.clear()
	for i in range(inventory_size):
		inventory.append({})

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

var last_lost_resources: Array = []

func reset_run() -> void:
	last_lost_resources = inventory.filter(func(slot): return not slot.is_empty())
	player_tile_index = 0
	player_current_health = -1
	loop_count = 0
	board_generated = false
	init_inventory()

func generate_board() -> void:
	tile_types.clear()
	
	var corners = [0, 9, 18, 27]
	var pool = []
	
	# Build pool of non-corner indices
	for i in range(36):
		if not corners.has(i):
			pool.append(i)
	
	pool.shuffle()
	
	# Assign corners as safe
	for i in corners:
		tile_types[i] = "safe"
	
	# Assign combat tiles
	for i in range(tile_combat):
		tile_types[pool[i]] = "combat"
	
	# Assign shop tiles
	for i in range(tile_combat, tile_combat + tile_shop):
		tile_types[pool[i]] = "shop"
	
	# Assign resource tiles
	for i in range(tile_combat + tile_shop, tile_combat + tile_shop + tile_resource):
		tile_types[pool[i]] = "resource"

	# Rest are safe
	for i in range(tile_combat + tile_shop + tile_resource, pool.size()):
		tile_types[pool[i]] = "safe"
		
	board_generated = true
