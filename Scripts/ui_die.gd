class_name UI_Die

extends Control

@export var faces:int = 0
#var die_scene = preload("res://scenes/ui_die.tscn")
signal on_playerdiceroll(roll_die_result)

func _update_ui() -> void:
	$Label.text = "D" + str(faces)

func _ready() -> void:
	_update_ui()

func _roll_die() -> void:
		var roll_die_result = randi_range(1, faces)
		on_playerdiceroll.emit(roll_die_result)

func _on_texture_button_pressed() -> void:
	_roll_die()
	pass # Replace with function body.
