# town_data.gd
extends Node

var town_storage: Dictionary = {
	"gold": 0,
	"wood": 0,
	"stone": 0
}

var buildings: Dictionary = {
	"blacksmith": false,
	"armoury": false,
	"jeweller": false,
	"apothecary": false,
	"training_grounds": false,
	"town_vault": false
}

var upgrades: Dictionary = {
	"blacksmith_strength": 0,
	"armoury_defense": 0,
	"jeweller_speed": 0,
	"apothecary_health": 0,
	"training_grounds_speed": 0,
	"town_vault_storage": 0
}

const MAX_UPGRADE_LEVEL = 5
const UPGRADE_BASE_COST = 10

# Which upgrade key belongs to which building
const BUILDING_UPGRADES = {
	"blacksmith": "blacksmith_strength",
	"armoury": "armoury_defense",
	"jeweller": "jeweller_speed",
	"apothecary": "apothecary_health",
	"training_grounds": "training_grounds_speed",
	"town_vault": "town_vault_storage"
}

# What each upgrade gives per level
const UPGRADE_STAT = {
	"blacksmith_strength": "strength",
	"armoury_defense": "defense",
	"jeweller_speed": "speed",
	"apothecary_health": "health",
	"training_grounds_speed": "speed",
	"town_vault_storage": "storage"
}

const UPGRADE_VALUE_PER_LEVEL = {
	"blacksmith_strength": 2,
	"armoury_defense": 2,
	"jeweller_speed": 1,
	"apothecary_health": 10,
	"training_grounds_speed": 1,
	"town_vault_storage": 2
}

signal town_storage_changed
signal building_constructed(building_name: String)
signal upgrade_purchased(upgrade_key: String)

func add_to_storage(resource_name: String, amount: int) -> void:
	if town_storage.has(resource_name):
		town_storage[resource_name] += amount
		town_storage_changed.emit()

func can_afford(cost: Dictionary) -> bool:
	for resource in cost:
		if town_storage.get(resource, 0) < cost[resource]:
			return false
	return true

func spend(cost: Dictionary) -> void:
	for resource in cost:
		town_storage[resource] -= cost[resource]
	town_storage_changed.emit()

func construct_building(building_name: String, cost: Dictionary) -> bool:
	if buildings[building_name]:
		print("❌ Already built!")
		return false
	if not can_afford(cost):
		print("❌ Can't afford %s" % building_name)
		return false
	spend(cost)
	buildings[building_name] = true
	building_constructed.emit(building_name)
	print("✅ Built %s!" % building_name)
	return true

func get_upgrade_level(building_name: String) -> int:
	var key = BUILDING_UPGRADES[building_name]
	return upgrades.get(key, 0)

func get_upgrade_cost(building_name: String) -> int:
	var level = get_upgrade_level(building_name)
	if level >= MAX_UPGRADE_LEVEL:
		return -1
	return int(UPGRADE_BASE_COST * pow(3, level))

func purchase_upgrade(building_name: String) -> bool:
	var key = BUILDING_UPGRADES[building_name]
	var level = upgrades.get(key, 0)
	if level >= MAX_UPGRADE_LEVEL:
		print("❌ Max level reached!")
		return false
	var cost = get_upgrade_cost(building_name)
	if town_storage["gold"] < cost:
		print("❌ Not enough gold!")
		return false
	town_storage["gold"] -= cost
	upgrades[key] += 1
	town_storage_changed.emit()
	upgrade_purchased.emit(key)
	print("✅ Upgraded %s to level %d!" % [building_name, upgrades[key]])
	return true

func get_upgrade_bonus(upgrade_key: String) -> int:
	return upgrades.get(upgrade_key, 0) * UPGRADE_VALUE_PER_LEVEL.get(upgrade_key, 0)
