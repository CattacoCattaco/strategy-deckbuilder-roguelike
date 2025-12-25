extends Node

const SAVE_PATH: String = "user://%s.json"


func save_stats() -> void:
	var file := FileAccess.open(SAVE_PATH % "stats", FileAccess.WRITE)
	file.store_string(JSON.stringify(StatsManager.values, "\t"))
	file.close()


func load_stats() -> bool:
	if FileAccess.file_exists(SAVE_PATH % "stats"):
		var file := FileAccess.open(SAVE_PATH % "stats", FileAccess.READ)
		var data: Variant = JSON.parse_string(file.get_as_text())
		file.close()
		if data is Array:
			for stat in len(data):
				StatsManager.values[stat] = roundi(data[stat])
		
		return true
	else:
		return false
