extends Node

var player_tile_index: int = 0
var board_generated: bool = false

var tile_combat: int = 5
var tile_shop: int = 2
var tile_resource: int = 20
var tile_types: Dictionary = {}

var current_enemy_data: Array[EnemyData] = []

var player_gold: int = 0
var player_current_health: int = -1
var player_max_health: int = 100

var carried_resources: Dictionary = {
	"gold": 0,
	"wood": 0,
	"stone": 0
}

var loop_count: int = 0

signal resources_changed

func _ready() -> void:
	SaveManager.load_save()
	if not board_generated:
		generate_board()
		board_generated = true

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
