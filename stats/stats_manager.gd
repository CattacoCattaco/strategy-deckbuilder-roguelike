extends Node

enum Stat {
	DISTANCE_TRAVELLED,
	LONGEST_MOVE,
	TOTAL_DAMAGE_CAUSED,
	MOST_DAMAGE_CAUSED,
	TOTAL_ATTACK_DAMAGE,
	LARGEST_ATTACK_SIZE,
	TOTAL_DAMAGE_HEALED,
	LARGEST_HEAL,
	TOTAL_POISON_DAMAGE,
	TOTAL_POISON_INCREASE,
	HIGHEST_POISON_LEVEL,
	TOTAL_AMOUNT_PUSHED,
	LARGEST_PUSH,
	TOTAL_PUSH_DAMAGE,
	HIGHEST_PUSH_DAMAGE,
	TOTAL_SHIELD_GAINED,
	HIGHEST_SHIELD_LEVEL,
	TOTAL_DAMAGE_BLOCKED,
	HIGHEST_DAMAGE_BLOCKED,
	SWAP_COUNT,
	FURTHEST_SWAP,
	TOTAL_DISTANCE_JUMPED,
	LONGEST_JUMP,
	## Not a real stat, just gives the number of stats
	STAT_COUNT,
}

const DESCRIPTIONS: Array[String] = [
	"Total distance travelled",
	"Longest distance travelled in a move action",
	"Total damage caused by the player",
	"Most damage caused by the player from a single action",
	"Total damage dealt in attacks",
	"Most damage dealt in a single attack",
	"Total damage healed",
	"Largest single heal",
	"Total amount of poison damage dealt",
	"Total amount of poison inflicted",
	"Largest poison level reached",
	"Total amount of pushing",
	"Largest single push size",
	"Total amount of push damage",
	"Largest instance of push damage",
	"Total amount of shield increase",
	"Largest shield level reached",
	"Total damage blocked",
	"Highest damage blocked at once",
	"Number of swaps performed",
	"Longest distance of any swap",
	"Total distance jumped",
	"Longest jump's distance",
]

var values: Array[int] = []


func _ready() -> void:
	for i in range(Stat.STAT_COUNT):
		values.append(0)
	
	if GameSaver.has_stats():
		GameSaver.load_stats()
	
	print(values)


func increase_total(amount: int, stat: Stat) -> void:
	values[stat] += amount
	GameSaver.save_stats()


func check_new_highest(amount: int, stat: Stat) -> void:
	if values[stat] < amount:
		values[stat] = amount
		GameSaver.save_stats()
