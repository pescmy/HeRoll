extends Node2D

@onready var player_stats: PlayerStats = $PlayerStats  # reference Player node's stats

# --- Enemy setup ---
var goblin_path: String = "res://enemies/Goblin.tres"
var enemy_stats  # don't type here; load() returns Variant

var turn: int = 0

func _ready() -> void:
	print("Combat started!")

	# --- Load enemy resource safely ---
	var enemy_res: Resource = load(goblin_path)
	enemy_stats = enemy_res.duplicate() as EnemyStats
	enemy_stats.setup()

	# --- Ensure player stats are initialized ---
	if player_stats.current_health == 0:
		player_stats.current_health = player_stats.max_health

	run_battle()

# --- Autobattler loop ---
func run_battle() -> void:
	while not player_stats.is_dead() and not enemy_stats.is_dead():
		turn += 1
		print("--- Turn %d ---" % turn)

		# Decide order by speed
		if player_stats.speed >= enemy_stats.speed:
			player_attack()
			if not enemy_stats.is_dead():
				enemy_attack()
		else:
			enemy_attack()
			if not player_stats.is_dead():
				player_attack()

	# --- Battle outcome ---
	if player_stats.is_dead():
		print("Player was defeated!")
	else:
		print("Enemy defeated!")

# --- Attacks ---
func player_attack() -> void:
	var roll: int = randi_range(1, 6)
	var amount: int = player_stats.strength + roll
	enemy_stats.take_damage(amount)
	print("Player hits enemy for %d (roll: %d)" % [amount, roll])

func enemy_attack() -> void:
	var roll: int = randi_range(1, 6)
	var dmg: int = enemy_stats.strength + roll
	player_stats.take_damage(dmg)
	print("Enemy hits player for %d (roll: %d)" % [dmg, roll])
