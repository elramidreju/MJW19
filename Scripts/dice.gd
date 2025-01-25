class_name Die
extends Node2D

@export var faces:int = 0
var die_scene = preload("res://scenes/dice.tscn")

func _ready() -> void:
	_update_ui()

func _update_ui()-> void:
	$Control/Label.text = "D" + str(faces)

func _process(delta: float) -> void:
	pass

func _on_use_button_pressed() -> void:
	print(randi_range(1, faces))
	queue_free()
	
func _split_die()-> void:
	$Control/SplitButton.visible = false
	$Control/SplitButton.set_process_input(false)
	$Control/SplitButton.set_process(false)
	faces = faces/2
	_update_ui()
func _instantiate_half_die()-> void:
	var new_half_die:Die = die_scene.instantiate() as Die
	new_half_die.position = $HalfDieSpawnPos.global_position
	new_half_die.faces = faces
	new_half_die._split_die()
	get_tree().current_scene.add_child(new_half_die)
	
func _on_split_button_pressed() -> void:
	_instantiate_half_die()
	_split_die()
