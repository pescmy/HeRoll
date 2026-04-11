extends Node2D
class_name Enemy

@export var data: EnemyData
@onready var stats: EnemyStats = $EnemyStats
@onready var sprite: Sprite2D = $Sprite2D

var display_name: String = ""

signal clicked(enemy: Node)

func _ready():
	if data:
		_apply_data()
	
	# Add clickable area
	var area = Area2D.new()
	area.name = "ClickArea"
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(48, 48)
	shape.shape = rect
	area.add_child(shape)
	add_child(area)
	area.input_pickable = true
	area.input_event.connect(_on_input_event)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self)

func _apply_data():
	name = data.name if data.name != "" else String(name)
	if stats:
		stats.setup(data)
	if data.sprite:
		sprite.texture = data.sprite

func take_damage(amount: int) -> int:
	if stats:
		return stats.take_damage(amount)
	return 0

func is_dead() -> bool:
	return stats and stats.is_dead()

func get_attack_damage() -> int:
	return stats.get_attack_damage()
