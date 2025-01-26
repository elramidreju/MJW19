extends Control

signal on_dice_result_text_anim_finished(roll_die_result)

func _disable() -> void:
	$Label.visible = false
	$TextureRect.visible = false

func _enable() -> void:
	$Label.visible = true
	$TextureRect.visible = true
	$TextureRect.size = Vector2(128.0, 128.0)

func _ready() -> void:
	_disable()
	
func set_label_text(text):
	$Label.text = text	

func _start_size_anim(new_texture_to_use) -> void:
	$TextureRect.texture = new_texture_to_use
	_enable()
	$AnimationPlayer.play("dice_result_size_anim")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	_disable()
	on_dice_result_text_anim_finished.emit()
