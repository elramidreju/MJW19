extends Node3D

enum EnemyType {MoreThan, Ranged, Odd}

@export_category("Enemy")
@export var enemy_condition:EnemyType
@export var condition_values: Array[int] = []

signal enemy_result(result:bool)

#SpriteAnimation2D
#Some kind of text to show the probability
#The condition should be set here, if, for the three

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	
	#get_node("TestSignal").on_player_diceroll.connect(_on_player_diceroll)
	
	if condition_values.size() == 0:
		pass
	update_name()
		
	#pass # Replace with function body.

func update_name() -> void:
	if enemy_condition == EnemyType.MoreThan: 
		$EnemyLabel.set_text("More Than %d" % condition_values[0])
	if enemy_condition == EnemyType.Ranged: 
		$EnemyLabel.set_text("%d to %d" % [condition_values[0], condition_values[1]])
	if enemy_condition == EnemyType.Odd: 
		$EnemyLabel.set_text("Odd Number")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func on_player_diceroll(die_value) -> bool:
	var condition_met := false
	if enemy_condition == EnemyType.MoreThan && die_value == condition_values[0]: 
		condition_met = true;
	if enemy_condition == EnemyType.Ranged:
		if die_value >= condition_values[0] && die_value <= condition_values[1]: 
			condition_met = true;
	if enemy_condition == EnemyType.Odd && die_value % 2 == 1: 
		condition_met = true;
	
	return condition_met
	enemy_result.emit(condition_met)
	#print("%s" % condition_met)
