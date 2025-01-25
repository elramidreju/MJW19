extends Node

@export var player_scene: PackedScene
@export var enemy_scene: Array[PackedScene] = []
@export var ui_die_scene: PackedScene
@export var player_health: int

var player: Node3D
var current_enemy: Node3D
var allowInput: bool = false
var encounterCounter: int = 0
var dice: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Root3D/EnemyPlaceholder.visible = false
	update_dice()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_start_timer_timeout() -> void:
	new_game()

func _on_player_spawn_timer_timeout() -> void:
	spawn_player()

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_next_enemy()

func update_dice() -> void:
	dice = find_children("*", "UI_Die");
	for die in dice:
		die.on_playerdiceroll.connect(_on_player_diceroll)
		die.on_playerdicesplit.connect(_on_player_dicesplit)


func new_game() -> void:
	print("Starting new game!")
	$PlayerSpawnTimer.start()
	$EnemySpawnTimer.start()

func end_game() -> void:
	print("Ending the game")

func spawn_player() -> void:
	player = player_scene.instantiate()
	
func spawn_next_enemy() -> void:
	
	if encounterCounter == enemy_scene.size():
		end_game()
		return
	
	current_enemy = enemy_scene[encounterCounter].instantiate()
	get_node("Root3D").add_child(current_enemy)
	current_enemy.transform = $Root3D/EnemyPlaceholder.transform
	encounterCounter += 1
	
func _on_player_diceroll(dice_value):
	
	if !$EnemySpawnTimer.is_stopped():
		return
	
	var condition_passed = current_enemy.on_player_diceroll(dice_value);
	if !condition_passed:
		player_health -= 1;

	current_enemy.queue_free()
	$EnemySpawnTimer.start()

func _on_player_dicesplit(new_die_pos:Vector2, new_die_size:Vector2, new_die_faces_num:int) -> void:
	var new_die:UI_Die = ui_die_scene.instantiate() as UI_Die
	$UIControl.add_child(new_die)
	new_die.faces = new_die_faces_num
	new_die._update_ui()
	new_die.global_position.x = new_die_pos.x
	new_die.global_position.y = new_die_pos.y
	new_die.set_size(new_die_size)

func _on_split_die():
	update_dice()
