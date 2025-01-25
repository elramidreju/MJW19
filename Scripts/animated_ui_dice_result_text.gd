extends Control

signal on_dice_result_text_anim_finished(roll_die_result)

func _disable() -> void:
	$Label.visible = false

func _enable() -> void:
	$Label.visible = true

func _ready() -> void:
	_disable()

func _start_size_anim() -> void:
	_enable()
	$AnimationPlayer.play("dice_result_size_anim")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$AnimationPlayer.stop()
	_disable()
	on_dice_result_text_anim_finished.emit()
