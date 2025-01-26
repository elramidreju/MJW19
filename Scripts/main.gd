extends Node

@export var player_scene: PackedScene
@export var mage_scene: PackedScene
@export var heart_scene: PackedScene
@export var enemy_scene: Array[PackedScene] = []
@export var health_element: PackedScene
@export var ui_die_scene: PackedScene
@export var die_3d_scene: PackedScene
@export var die_D8: PackedScene
@export var die_D6: PackedScene
@export var die_D4: PackedScene
@export var die_D3: PackedScene
@export var ui_d8_textures: Array[Texture2D] = []
@export var ui_d6_textures: Array[Texture2D] = []
@export var ui_d4_textures: Array[Texture2D] = []
@export var ui_d3_textures: Array[Texture2D] = []
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
var last_rolled_die_faces:int = 0

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
	if current_enemy != null && $EnemySpawnTimer.is_stopped():
		if current_enemy.position.x > $Root3D/EnemyPlaceholder.position.x:
			current_enemy.position.x -= delta * 0.15
		
		if current_enemy.position.x < $Root3D/EnemyPlaceholder.position.x:
			current_enemy.position.x = $Root3D/EnemyPlaceholder.position.x
	
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
		if not die.is_connected("on_playerdiceroll", _on_player_diceroll):
			die.on_playerdiceroll.connect(_on_player_diceroll)
		else:
			print("Skipping singal connection since it is already connected")
		
		if not die.is_connected("on_playerdicesplit", _on_player_dicesplit):
			die.on_playerdicesplit.connect(_on_player_dicesplit)
		else:
			print("Skipping signal connection since it is already connected")

func new_game() -> void:
	print("Starting new game!")
	$PlayerSpawnTimer.start()
	$EnemySpawnTimer.start()

func end_game() -> void:
	_enable_disable_ui_input(false)
	if player_health > 0:
		var mage = mage_scene.instantiate()
		get_node("Root3D").add_child(mage)
		#mage.transform = $Root3D/EnemyPlaceholder.transform
		#mage.position.y = $Root3D/PlayerPlaceholder.position.y
		mage.transform = $Root3D/MagePlaceHolder.transform
		
		var animated_heart = heart_scene.instantiate()
		$UIControl/AnimatedHeartSpawnPos.add_child(animated_heart)
		var animated_heart_anim_player = animated_heart.get_child(2) as AnimationPlayer
		
		if animated_heart_anim_player != null:
			animated_heart_anim_player.play("dice_result_size_anim")
		
		await get_tree().create_timer(2).timeout
	
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

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
	current_enemy.position.y = player.position.y
	current_enemy.position.x = 0.4
	
	_enable_disable_ui_input(true)

func _spawn_3d_die():
	var die_to_inst: PackedScene = null
	
	match last_rolled_die_faces:
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
	
	last_rolled_die_faces = rolled_die.faces
	_spawn_3d_die()
	dice.erase(rolled_die)
	
	rolled_die.queue_free()
	
	last_rolled_die_condition = current_enemy.on_player_diceroll(dice_value);
	#if !last_rolled_die_condition:
		#_player_receives_damage()
	
	get_node("UIControl/AnimatedDiceResultText/Label").text = str(dice_value)

func _on_player_dicesplit(new_die_pos:Vector2, new_die_size:Vector2, new_die_faces_num:int, old_die) -> void:
	var new_die:UI_Die = ui_die_scene.instantiate() as UI_Die
	$UIControl.add_child(new_die)
	new_die.faces = new_die_faces_num
	
	match new_die_faces_num:
		3: new_die.button_textures = ui_d3_textures
		4: new_die.button_textures = ui_d4_textures
		6: new_die.button_textures = ui_d6_textures
		8: new_die.button_textures = ui_d8_textures
	
	old_die.button_textures = new_die.button_textures
	old_die._update_ui()
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
		
	var anim_texture: Texture = null
	
	match last_rolled_die_faces:
		3: anim_texture = ui_d3_textures[0]
		4: anim_texture = ui_d4_textures[0]
		6: anim_texture = ui_d6_textures[0]
		8: anim_texture = ui_d8_textures[0]
		
	$UIControl/AnimatedDiceResultText._start_size_anim(anim_texture)

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
