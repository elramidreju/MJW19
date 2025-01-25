class_name UI_Die

extends Control

@export var faces:int = 0

signal on_playerdiceroll(roll_die_result)
signal on_playerdicesplit(new_die_pos, new_die_size, new_die_faces_num)

func _update_ui() -> void:
	$Label.text = "D" + str(faces)

func _ready() -> void:
	_update_ui()

func _roll_die() -> void:
	var roll_die_result = randi_range(1, faces)
	on_playerdiceroll.emit(roll_die_result)

func _split_die()-> void:
	faces = faces/2
	_update_ui()
	
func _instantiate_half_die() -> void:
	if faces <= 4:
		return
		
	_split_die()
	
	var new_die_pos = Vector2(global_position.x, global_position.y) 
	new_die_pos.x += get_size().x
	on_playerdicesplit.emit(new_die_pos, get_size(), faces)

func _roll_split() -> void:
	_instantiate_half_die()
	#_split_die()

func _on_texture_button_pressed() -> void:
	#if Input.is_action_just_pressed("LMouse"):
	#	_roll_die()
	#if Input.is_action_just_pressed("RMouse"):
		_roll_split()
