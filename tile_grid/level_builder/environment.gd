class_name LevelEnvironment
extends Resource

@export var clump_obstacles: WeightedObjectList
@export var single_obstacles: WeightedObjectList
@export var defendables: WeightedObjectList

## The minimum clump count as a percent of the level area on dense density
@export var min_clump_count: float = 0.06
## The maximum clump count as a percent of the level area on dense density
@export var max_clump_count: float = 0.1
## The minimum clump size on dense density
@export var min_clump_size: int = 4
## The maximum clump size on dense density
@export var max_clump_size: int = 11
## The minimum single object count as a percent of the level area on dense density
@export var min_single_count: float = 0.15
## The maximum single object count as a percent of the level area on dense density
@export var max_single_count: float = 0.2


func _init(p_clump_obstacles: WeightedObjectList = WeightedObjectList.new(),
		p_single_obstacles: WeightedObjectList = WeightedObjectList.new(),
		p_defendables: WeightedObjectList = WeightedObjectList.new()) -> void:
	clump_obstacles = p_clump_obstacles
	single_obstacles = p_single_obstacles
	defendables = p_defendables


func get_clump_count(density: LevelBuilder.ObjectDensity, area: int) -> int:
	var clump_count: float = randf_range(min_clump_count, max_clump_count) * area
	
	match density:
		LevelBuilder.ObjectDensity.SPARSE:
			clump_count *= 0.15
		LevelBuilder.ObjectDensity.MILD:
			clump_count *= 0.3
		LevelBuilder.ObjectDensity.FEATUREFUL:
			clump_count *= 0.6
		LevelBuilder.ObjectDensity.DENSE:
			clump_count *= 1
	
	return mini(maxi(floori(clump_count), 1), ceili(max_single_count * area))


func get_clump_size(density: LevelBuilder.ObjectDensity) -> int:
	var clump_size: float = randf_range(min_clump_size, max_clump_size)
	
	match density:
		LevelBuilder.ObjectDensity.SPARSE:
			clump_size *= 0.25
		LevelBuilder.ObjectDensity.MILD:
			clump_size *= 0.5
		LevelBuilder.ObjectDensity.FEATUREFUL:
			clump_size *= 0.75
		LevelBuilder.ObjectDensity.DENSE:
			clump_size *= 1
	
	return maxi(roundi(clump_size), 1)


func get_single_object_count(density: LevelBuilder.ObjectDensity, area: int) -> int:
	var single_object_count: float = randf_range(min_single_count, max_single_count) * area
	
	match density:
		LevelBuilder.ObjectDensity.SPARSE:
			single_object_count *= 0.15
		LevelBuilder.ObjectDensity.MILD:
			single_object_count *= 0.3
		LevelBuilder.ObjectDensity.FEATUREFUL:
			single_object_count *= 0.6
		LevelBuilder.ObjectDensity.DENSE:
			single_object_count *= 1
	
	return mini(maxi(floori(single_object_count), 1), ceili(max_single_count * area))
