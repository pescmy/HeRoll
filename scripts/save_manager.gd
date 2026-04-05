# save_manager.gd
extends Node

const SAVE_PATH = "user://save.json"

func save() -> void:
	var data = {
		"player_tile_index": GameData.player_tile_index,
		"player_current_health": GameData.player_current_health,
		"player_max_health": GameData.player_max_health,
		"loop_count": GameData.loop_count,
		"inventory": GameData.inventory,
		"tile_types": GameData.tile_types,
		"board_generated": GameData.board_generated,
		"town_storage": TownData.town_storage,
		"buildings": TownData.buildings,
		"upgrades": TownData.upgrades,
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("💾 Game saved")

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found")
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if data == null:
		print("❌ Failed to parse save file")
		return
	
	GameData.player_tile_index = data["player_tile_index"]
	GameData.player_current_health = data["player_current_health"]
	GameData.player_max_health = data["player_max_health"]
	GameData.loop_count = data["loop_count"]
	GameData.inventory = data["inventory"]
	GameData.board_generated = data["board_generated"]
	
	var tile_types: Dictionary = {}
	for key in data["tile_types"]:
		tile_types[int(key)] = data["tile_types"][key]
	GameData.tile_types = tile_types
	
	TownData.town_storage = data["town_storage"]
	TownData.buildings = data["buildings"]
	TownData.upgrades = data["upgrades"]
	
	print("✅ Game loaded")

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("🗑️ Save deleted")
