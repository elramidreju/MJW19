extends Node

@export var dice_test:int
signal on_player_diceroll(dice_value:int)




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	on_player_diceroll.emit(dice_test)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	on_player_diceroll.emit(dice_test)
