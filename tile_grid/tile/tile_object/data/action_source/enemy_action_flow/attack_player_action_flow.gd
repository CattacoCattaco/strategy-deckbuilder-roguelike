class_name AttackPlayerActionFlow
extends ActionFlowComponent
## Attacks the player

## The range of the attack
@export var attack_range: int = 1
## The damage dealt
@export var attack_damage: int = 1


func _init(p_attack_range: int = 1, p_attack_damage: int = 1) -> void:
	attack_range = p_attack_range
	attack_damage = p_attack_damage


func _resolve(object: TileObject, action_source: EnemyActionSource) -> void:
	var player_pos: Vector2i = object.tile_grid.hand.player.pos
	
	action_source.next_action = CardData.new([Modifier.Attack.new()], attack_range, attack_damage)
	action_source.next_action_targets = [player_pos]
