class_name UI_Die
extends Control

@export var faces:int = 0
@export var half_die_x_offset:float = 0

var input_enabled:bool = true

@export var button_textures: Array[Texture2D] = []

signal on_playerdiceroll(rolled_die, roll_die_result)
signal on_playerdicesplit(new_die_pos, new_die_size, new_die_faces_num, old_die)

func _set_input_enabled(new_value:bool) -> void:
	input_enabled = new_value

func _update_ui() -> void:
	$Label.text = "D" + str(faces)
	$TextureButton.texture_normal = button_textures[0]
	$TextureButton.texture_pressed = button_textures[1]
	$TextureButton.texture_hover = button_textures[2]
	
func _ready() -> void:
	_update_ui()

func _handle_input() -> void:
	var mouse_pos_viewport:Vector2 =  get_viewport().get_mouse_position()
	if input_enabled && mouse_pos_viewport.x >= global_position.x && mouse_pos_viewport.x <= global_position.x + get_size().x && mouse_pos_viewport.y >= global_position.y && mouse_pos_viewport.y <= global_position.y + get_size().y :
		if Input.is_action_just_pressed("LMouse"):
			_roll_die()
		if Input.is_action_just_pressed("RMouse"):
			_roll_split()

func _process(delta: float) -> void:
	_handle_input()	

func _roll_die() -> void:
	var roll_die_result = randi_range(1, faces)
	on_playerdiceroll.emit(self, roll_die_result)

func _instantiate_half_die() -> void:
	faces = faces/2
	
	var new_die_pos = Vector2(global_position.x, global_position.y) 
	new_die_pos.x += get_size().x + half_die_x_offset
	on_playerdicesplit.emit(new_die_pos, get_size(), faces, self)

func _roll_split() -> void:
	if faces <= 4:
		return
	_instantiate_half_die()
