extends Node3D

var player_sprite = AnimatedSprite3D

var idle_animation

var AnimationsToPlay : Array[String] = []

var initial_bubble_position
var initial_bubble_scale
var initial_bubble_sprite
var bubble_time := 0.0
var elapsed_time := 0.0
@export var exploded_bubble : Texture

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#player_sprite = get_node("AnimatedSprite3D")
	$AnimatedSprite3D.play("idle")
	$AnimatedSprite3D.animation_finished.connect(_animation_finished)
	
	initial_bubble_position = $BubbleSprite.position
	initial_bubble_scale = $BubbleSprite.scale
	initial_bubble_sprite = $BubbleSprite.texture
	$BubbleSprite.visible = false
	$BubbleSprite.modulate.a = 0.6
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$BubbleAttackTimer.is_stopped():
		bubble_time+=delta
		$BubbleSprite.position += Vector3(delta, -delta * 0.8, 0.0) * 2
		
		#var random = RandomNumberGenerator.new().randfn(0.0, 0.1) * delta
		#$BubbleSprite.position += Vector3(random, random, 0.0)
		$BubbleSprite.scale += Vector3(delta, delta, delta) * 0.05
	
	elapsed_time+=delta
	$AnimatedSprite3D.rotation.y += sin(elapsed_time * 3) * 0.015

func _animation_finished():
	if AnimationsToPlay.size() == 0:
		$AnimatedSprite3D.play("idle")
	else:
		$AnimatedSprite3D.play(AnimationsToPlay.pop_front())
	
	
func eat_anim():
	add_anim_to_queue("eat")
func attack_anim():
	add_anim_to_queue("attack")
	reset_bubble()
	
func react_to_damage_anim():
	add_anim_to_queue("react_to_damage")

func spawn_anim():
	add_anim_to_queue("spawn")
	
func add_anim_to_queue(anim_name):
	AnimationsToPlay.push_back(anim_name)
	
func reset_bubble():
	$BubbleSprite.position = initial_bubble_position
	$BubbleSprite.scale = initial_bubble_scale
	$BubbleSprite.texture = initial_bubble_sprite
	$BubbleSprite.visible = true
	bubble_time = 0.0
	$BubbleAttackTimer.start()


func _on_bubble_attack_timer_timeout() -> void:
	$BubbleSprite.texture = exploded_bubble
	await get_tree().create_timer(0.3).timeout
	$BubbleSprite.visible = false
