class_name PoisonActionFlow
extends ActionFlowComponent
## Attacks something in range

## The probability of choosing to attack the player if both the player and
## a defendable are in range
@export var player_weight: float = 1.0
## The range of the attack
@export var poison_range: int = 1
## Does the range jump?
@export var can_jump: bool = false
## The damage dealt
@export var poison_damage: int = 1


func _init(p_player_weight: float = 1.0, p_poison_range: int = 1, p_can_jump: bool = false,
		p_poison_damage: int = 1) -> void:
	player_weight = p_player_weight
	poison_range = p_poison_range
	can_jump = p_can_jump
	poison_damage = p_poison_damage


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var attackable_player: TileObject
	var attackable_defendables: Array[TileObject] = []
	for tile in object.get_tiles_in_range(poison_range, can_jump, Modifier.Poison.new()):
		match tile.object.data.object_type:
			TileObjectData.ObjectType.PLAYER:
				attackable_player = tile.object
			TileObjectData.ObjectType.DEFENDABLE:
				attackable_defendables.append(tile.object)
	
	var target_pos: Vector2i
	if attackable_player and attackable_defendables:
		if randf() < player_weight:
			target_pos = attackable_player.pos
		else:
			target_pos = attackable_defendables.pick_random().pos
	elif attackable_player:
		target_pos = attackable_player.pos
	elif attackable_defendables:
		target_pos = attackable_defendables.pick_random().pos
	else:
		target_pos = Vector2i(-1, -1)
	
	var modifiers: Array[Modifier] = [Modifier.Poison.new()]
	if can_jump:
		modifiers.append(Modifier.Jump.new())
	
	action_source.next_action = CardData.new(modifiers, poison_range, poison_damage)
	action_source.next_action_targets = [target_pos]
