extends Node

var player_tile_index: int = 0

var tile_combat: int = 30
var tile_shop: int = 2

var current_enemy_data: Array[EnemyData] = []
var tile_types: Dictionary = {}

var player_gold: int = 0
var player_current_health: int = -1


var loop_count: int = 0

func _ready() -> void:
	generate_board()

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
	
	# Rest are safe
	for i in range(tile_combat + tile_shop, pool.size()):
		tile_types[pool[i]] = "safe"
