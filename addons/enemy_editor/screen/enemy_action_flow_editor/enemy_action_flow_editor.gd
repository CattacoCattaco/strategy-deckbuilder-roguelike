@tool
class_name EnemyActionFlowEditor
extends PanelContainer

signal action_flow_updated()

@export var action_flow_type_options: OptionButton
@export var options_container: GridContainer

var enemy_editor_screen: EnemyEditorScreen

var action_flow: ActionFlowComponent


func _ready() -> void:
	action_flow_type_options.item_selected.connect(_set_action_flow_type)


func _set_action_flow_type(type: int) -> void:
	match type:
		0:
			action_flow = AttackActionFlow.new()
		1:
			action_flow = ClumpOrDisperseActionFlow.new()
		2:
			action_flow = DefendableAmountCheckActionFlow.new()
		3:
			action_flow = DistanceCheckActionFlow.new()
		4:
			action_flow = EnemyAmountCheckActionFlow.new()
		5:
			action_flow = EnemyDistanceCheckActionFlow.new()
		6:
			action_flow = HealEnemyActionFlow.new()
		7:
			action_flow = MoveCloserFurtherActionFlow.new()
		8:
			action_flow = NullActionFlow.new()
		9:
			action_flow = PoisonActionFlow.new()
		10:
			action_flow = RandomActionFlow.new()
	
	action_flow_updated.emit()
