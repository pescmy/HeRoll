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
	"max_health": 0,
	"strength": 0,
	"defense": 0,
	"speed": 0
}

signal town_storage_changed
signal building_constructed(building_name: String)

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

func get_upgrade_cost(upgrade_name: String) -> int:
	return (upgrades[upgrade_name] + 1) * 10

func purchase_upgrade(upgrade_name: String) -> bool:
	var cost = get_upgrade_cost(upgrade_name)
	if town_storage["gold"] < cost:
		print("❌ Not enough gold!")
		return false
	town_storage["gold"] -= cost
	upgrades[upgrade_name] += 1
	town_storage_changed.emit()
	print("✅ Upgraded %s to level %d!" % [upgrade_name, upgrades[upgrade_name]])
	return true
