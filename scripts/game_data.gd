extends Node

var current_enemy_data: EnemyData = null
var tile_types: Dictionary = {}

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
	for i in range(10):
		tile_types[pool[i]] = "combat"
	
	# Assign shop tiles
	for i in range(10, 12):
		tile_types[pool[i]] = "shop"
	
	# Rest are safe
	for i in range(12, pool.size()):
		tile_types[pool[i]] = "safe"
