class_name UnlockCond
extends RefCounted

var stat: StatsManager.Stat
var req: int
var description: String


func _init(p_stat: StatsManager.Stat = StatsManager.Stat.DISTANCE_TRAVELLED, p_req: int = 0,
		p_description: String = "") -> void:
	stat = p_stat
	req = p_req
	description = p_description


func is_complete() -> bool:
	return StatsManager.values[stat] >= req


func get_text() -> String:
	return "%s (%d/%d)" % [description, StatsManager.values[stat], req]
