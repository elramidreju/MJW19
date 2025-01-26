extends Node

@export var player_scene: PackedScene
@export var enemy_scene: Array[PackedScene] = []
@export var health_element: PackedScene
@export var ui_die_scene: PackedScene
@export var die_3d_scene: PackedScene
@export var die_D8: PackedScene
@export var die_D6: PackedScene
@export var die_D4: PackedScene
@export var die_D3: PackedScene
@export var player_health: int
@export var health_texture_filled: Texture
@export var health_texture_empty: Texture

var player: Node3D
var current_enemy: Node3D
var allowInput: bool = false
var encounterCounter: int = 0
var dice: Array[Node] = []
var health_elements: Array[Node] = []
var enemy_condition_passed
var last_rolled_die_condition:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$UIControl/AnimatedDiceResultText.on_dice_result_text_anim_finished.connect(_on_animation_player_animation_finished)
	$Root3D/EnemyPlaceholder.visible = false
	$Root3D/PlayerPlaceholder.visible = false
	$UIControl/Mosquitoe_placeholder.visible = false
	update_dice()
	_enable_disable_ui_input(false)
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
	var ui_control_children = $UIControl.get_children()
	for ui_control_child in ui_control_children:
		if ui_control_child is UI_Die && dice.has(ui_control_child) == false:
			dice.append(ui_control_child)

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
	
	current_enemy = enemy_scene[encounterCounter].instantiate()
	get_node("Root3D").add_child(current_enemy)
	current_enemy.transform = $Root3D/EnemyPlaceholder.transform
	
	_enable_disable_ui_input(true)

func _spawn_3d_die(faces: int):
	
	var die_to_inst: PackedScene = null
	
	match faces:
		3: die_to_inst = die_D3
		4: die_to_inst = die_D4
		6: die_to_inst = die_D6
		8: die_to_inst = die_D8
	
	if (die_to_inst == null):
		printerr("Number of faces not supported")
		return
	
	var new_3d_die:Node3D = die_to_inst.instantiate() as Node3D
	$Root3D/Spawned3DDice.add_child(new_3d_die)
	new_3d_die.global_position = $Root3D/Spawned3DDice.global_position
	$Despawn3DDiceTimer.start()

func _enable_disable_ui_input(new_value:bool) -> void:
	$UIControl/PassButton.disabled = !new_value
	for die in dice:
		die._set_input_enabled(new_value)

func _player_receives_damage() -> void:
	player_health -= 1;
	player.react_to_damage_anim()
	player.eat_anim()
	update_life()
	
	if(player_health == 0):
		end_game()

func _on_player_diceroll(rolled_die, dice_value):
	if !$EnemySpawnTimer.is_stopped():
		return
	_enable_disable_ui_input(false)
	
	player.attack_anim()
	
	_spawn_3d_die(rolled_die.faces)
	dice.erase(rolled_die)
	
	rolled_die.queue_free()
	
	last_rolled_die_condition = current_enemy.on_player_diceroll(dice_value);
	if !last_rolled_die_condition:
		_player_receives_damage()
	
	get_node("UIControl/AnimatedDiceResultText/Label").text = str(dice_value)

func _on_player_dicesplit(new_die_pos:Vector2, new_die_size:Vector2, new_die_faces_num:int) -> void:
	var new_die:UI_Die = ui_die_scene.instantiate() as UI_Die
	$UIControl.add_child(new_die)
	new_die.faces = new_die_faces_num
	new_die._update_ui()
	new_die.global_position.x = new_die_pos.x
	new_die.global_position.y = new_die_pos.y
	new_die.set_size(new_die_size)
	update_dice()

func update_life():
	
	if health_elements.size() == 0:
		for i in 3:
			var new_element = health_element.instantiate()
			get_node("UIControl").add_child(new_element)
			new_element.global_position = $UIControl/Mosquitoe_placeholder.global_position
			new_element.global_position.x += 200.0 * i
			new_element.texture = health_texture_filled
			health_elements.push_back(new_element)
	
	var counter = 1
	for health_ui in health_elements:
		if(counter <= player_health):
			health_ui.texture = health_texture_filled
		else:
			health_ui.texture = health_texture_empty
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

func _swap_to_next_enemy() -> void:
	if encounterCounter == enemy_scene.size():
		end_game()
		return
	
	if encounterCounter == enemy_scene.size() || !$EnemySpawnTimer.is_stopped():
		return
	current_enemy.respond_to_condition_result(last_rolled_die_condition)
	last_rolled_die_condition = false
	await get_tree().create_timer(1.5).timeout
	current_enemy.queue_free()
	encounterCounter += 1
	$EnemySpawnTimer.start()
	
func _on_animation_player_animation_finished() -> void:
	if encounterCounter == enemy_scene.size() || !$EnemySpawnTimer.is_stopped():
		return
	if !last_rolled_die_condition:
		_player_receives_damage()
	_swap_to_next_enemy()

func _on_pass_button_pressed() -> void:
	if encounterCounter == enemy_scene.size() || !$EnemySpawnTimer.is_stopped():
		return
	_player_receives_damage()
	_enable_disable_ui_input(false)
	_swap_to_next_enemy()
