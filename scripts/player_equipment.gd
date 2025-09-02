extends Node
class_name PlayerEquipment

signal equipment_changed

@export var equipped_weapon: Item
@export var equipped_armor: Item
@export var equipped_accessory: Item

func _ready() -> void:
	print("[Equipment] Ready. Weapon=%s Armor=%s Accessory=%s"
		% [_name_or_none(equipped_weapon), _name_or_none(equipped_armor), _name_or_none(equipped_accessory)])

func equip(item: Item) -> void:
	if item == null:
		return
	match item.type:
		"weapon":
			equipped_weapon = item
		"armor":
			equipped_armor = item
		"accessory":
			equipped_accessory = item
	print("[Equipment] Equipped %s (%s)" % [item.name, item.type])
	emit_signal("equipment_changed")

func unequip(slot: String) -> void:
	match slot:
		"weapon":
			equipped_weapon = null
		"armor":
			equipped_armor = null
		"accessory":
			equipped_accessory = null
	print("[Equipment] Unequipped %s" % slot)
	emit_signal("equipment_changed")

func get_total_bonuses() -> Dictionary:
	var totals := {
		"health": 0,
		"strength": 0,
		"defense": 0,
		"speed": 0,
	}
	for item in _iter_equipped():
		totals.health += item.health_bonus
		totals.strength += item.strength_bonus
		totals.defense += item.defense_bonus
		totals.speed += item.speed_bonus
	return totals

func get_equipment_summary() -> String:
	var s := ""
	s += "Weapon: %s\n" % _name_or_none(equipped_weapon)
	s += "Armor: %s\n" % _name_or_none(equipped_armor)
	s += "Accessory: %s\n" % _name_or_none(equipped_accessory)
	return s

func print_equipment() -> void:
	print(get_equipment_summary())

# --- helpers ---
func _iter_equipped() -> Array:
	var out: Array = []
	if equipped_weapon != null:
		out.append(equipped_weapon)
	if equipped_armor != null:
		out.append(equipped_armor)
	if equipped_accessory != null:
		out.append(equipped_accessory)
	return out

func _name_or_none(it: Item) -> String:
	return it.name if it != null else "None"
