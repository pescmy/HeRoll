extends Resource
class_name EnemyData

@export var name: String = "Enemy"
@export var max_health: int = 20
@export var strength: int = 5
@export var defense: int = 2
@export var speed: int = 1
@export var sprite: Texture2D   # optional, for combat visuals
@export var reward_gold: int = 0
@export var reward_xp: int = 0
