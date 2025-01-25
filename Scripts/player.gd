extends Node3D

var player_sprite = AnimatedSprite3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player_sprite = get_node("AnimatedSprite3D")
	$AnimatedSprite3D.play("idle")
	
	$AnimatedSprite3D.animation_finished.connect(_animation_finished)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _animation_finished():
	$AnimatedSprite3D.play("idle")
	
func eat_anim():
	$AnimatedSprite3D.play("eat")
func attack_anim():
	$AnimatedSprite3D.play("attack")
func react_to_damage_anim():
	$AnimatedSprite3D.play("react_to_damage")
func spawn_anim():
	$AnimatedSprite3D.play("spawn")
