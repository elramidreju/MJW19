extends Node3D

var rotSpeed : float = 1.0
var rotDirection : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotDirection = Vector3(360.0 * randf(), 360.0 * randf(), 360.0 * randf())
	print("Rotation direction is " + str(rotDirection))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotate(rotDirection, rotSpeed)
