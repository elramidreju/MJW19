extends Node

@export var player_scene: PackedScene
@export var enemy_scene: Array[PackedScene] = []
@export var health_element: PackedScene
@export var ui_die_scene: PackedScene
@export var die_3d_scene: PackedScene
@export var player_health: int

var player: Node3D
var current_enemy: Node3D
var allowInput: bool = false
var encounterCounter: int = 0
var dice: Array[Node] = []
var health_elements: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UIControl/AnimatedDiceResultText.on_dice_result_text_anim_finished.connect(_on_animation_player_animation_finished)
	$Root3D/EnemyPlaceholder.visible = false
	$Root3D/PlayerPlaceholder.visible = false
	$UIControl/Mosquitoe_placeholder.visible = false
	update_dice()
	update_life()

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
	get_node("Root3D").add_child(player)
	player.transform = $Root3D/PlayerPlaceholder.transform
	player.spawn_anim()
	
func spawn_next_enemy() -> void:
	
	if encounterCounter == enemy_scene.size():
		end_game()
		return
	
	current_enemy = enemy_scene[encounterCounter].instantiate()
	get_node("Root3D").add_child(current_enemy)
	current_enemy.transform = $Root3D/EnemyPlaceholder.transform
	encounterCounter += 1
	
func _spawn_3d_die():
	var new_3d_die:Node3D = die_3d_scene.instantiate() as Node3D
	$Root3D/Spawned3DDice.add_child(new_3d_die)
	new_3d_die.global_position = $Root3D/Spawned3DDice.global_position
	$Despawn3DDiceTimer.start()
	
func _on_player_diceroll(dice_value):
	if !$EnemySpawnTimer.is_stopped():
		return
	
	player.attack_anim()
		
	_spawn_3d_die()
	var condition_passed = current_enemy.on_player_diceroll(dice_value);
	if !condition_passed:
		player_health -= 1;
		player.react_to_damage_anim()
		player.eat_anim()
		update_life()
	
	if(player_health == 0):
		end_game()

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
	
func update_life():
	
	if health_elements.size() == 0:
		for i in 3:
			var new_element = health_element.instantiate()
			get_node("UIControl").add_child(new_element)
			new_element.global_position = $UIControl/Mosquitoe_placeholder.global_position
			new_element.global_position.x += 150.0 * i
			health_elements.push_back(new_element)
	
	var counter = 1
	for health_ui in health_elements:
		if(counter <= player_health):
			health_ui.visible = true
		else:
			health_ui.visible = false
		counter+=1

func _on_despawn_rolled_dice_timer_timeout() -> void:
	var rolled_dice = $Root3D/Spawned3DDice.get_children()
	for die in rolled_dice:
		die.queue_free()

func _on_despawn_3d_dice_timer_timeout() -> void:
	var rolled_dice = $Root3D/Spawned3DDice.get_children()
	for die in rolled_dice:
		die.queue_free()
	$UIControl/AnimatedDiceResultText._start_size_anim()

func _on_animation_player_animation_finished() -> void:
	var test:int = 0
	pass
