# combat_reward.gd
extends Node
class_name CombatReward

const WEAPON_NAMES = ["Iron Sword", "Steel Blade", "War Axe", "Dagger", "Mace"]
const ARMOUR_NAMES = ["Leather Armour", "Chain Mail", "Iron Plate", "Hide Vest", "Scale Mail"]
const ACCESSORY_NAMES = ["Boots", "Ring of Power", "Amulet", "Bracers", "Lucky Charm"]

const STAR_GOLD_BONUS = {1: 5, 2: 10, 3: 20}

func calculate_gold(defeated: Array[EnemyData], stars: int) -> int:
	var total = 0
	for enemy in defeated:
		total += enemy.reward_gold
	total += STAR_GOLD_BONUS.get(stars, 0)
	total += GameData.loop_count * 2
	return total

func roll_drops(defeated: Array[EnemyData]) -> Array[Item]:
	var drops: Array[Item] = []
	for enemy in defeated:
		if randf() < enemy.drop_chance:
			drops.append(_generate_item(enemy.get_threat()))
	return drops

func _generate_item(threat: float) -> Item:
	var types = ["weapon", "armour", "accessory"]
	var type = types.pick_random()
	var item = Item.new()
	item.type = type
	var budget = int(threat) + GameData.loop_count

	match type:
		"weapon":
			item.name = WEAPON_NAMES.pick_random()
			item.strength_bonus = budget
		"armour":
			item.name = ARMOUR_NAMES.pick_random()
			item.defense_bonus = randi_range(1, budget - 1) if budget > 1 else 1
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
