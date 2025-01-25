extends Node

@export var player_scene: PackedScene
@export var enemy_scene: PackedScene

var player: Node3D
var allowInput: bool = false
var encounterCounter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_start_timer_timeout() -> void:
	new_game()

func _on_player_spawn_timer_timeout() -> void:
	spawn_player()

func _on_enemy_spawn_timer_timeout() -> void:
	pass

func new_game() -> void:
	print("Starting new game!")
	$PlayerSpawnTimer.start()

func spawn_player() -> void:
	player = player_scene.instantiate()
	
func _on_player_diceroll(dice_value):
	get_node("Enemy").on_player_diceroll(dice_value);
