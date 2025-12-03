class_name AttackActionFlow
extends ActionFlowComponent
## Attacks something in range

## The probability of choosing to attack the player if both the player and
## a defendable are in range
@export var player_weight: float = 1.0
## The range of the attack
@export var attack_range: int = 1
## Does the range jump?
@export var can_jump: bool = false
## The damage dealt
@export var attack_damage: int = 1


func _init(p_player_weight: float = 1.0, p_attack_range: int = 1, p_can_jump: bool = false,
		p_attack_damage: int = 1) -> void:
	player_weight = p_player_weight
	attack_range = p_attack_range
	can_jump = p_can_jump
	attack_damage = p_attack_damage


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var attackable_player: TileObject
	var attackable_defendables: Array[TileObject] = []
	for tile in object.get_tiles_in_range(attack_range, can_jump, true):
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
	
	var modifiers: Array[Modifier] = [Modifier.Attack.new()]
	if can_jump:
		modifiers.append(Modifier.Jump.new())
	
	action_source.next_action = CardData.new(modifiers, attack_range, attack_damage)
	action_source.next_action_targets = [target_pos]
