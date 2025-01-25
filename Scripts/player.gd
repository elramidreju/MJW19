extends Node3D

var player_sprite = AnimatedSprite3D

var AnimationsToPlay : Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player_sprite = get_node("AnimatedSprite3D")
	$AnimatedSprite3D.play("idle")
	
	$AnimatedSprite3D.animation_finished.connect(_animation_finished)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _animation_finished():
	if AnimationsToPlay.size() == 0:
		$AnimatedSprite3D.play("idle")
	else:
		$AnimatedSprite3D.play(AnimationsToPlay.pop_front())
	
	
func eat_anim():
	add_anim_to_queue("eat")
func attack_anim():
	add_anim_to_queue("attack")
func react_to_damage_anim():
	add_anim_to_queue("react_to_damage")
func spawn_anim():
	add_anim_to_queue("spawn")
	
func add_anim_to_queue(anim_name):
	AnimationsToPlay.push_back(anim_name)
