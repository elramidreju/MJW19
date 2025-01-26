extends Node3D

var rotSpeed : float = 0.2
var rotDirection : Vector3 = Vector3.ZERO
var rotDirection2 : Vector3 = Vector3.ZERO
var elapsedTime : float = 0.0

func _ready() -> void:
	rotDirection = Vector3(360.0 * randf(), 360.0 * randf(), 360.0 * randf())
	rotDirection2 = Vector3(360.0 * randf(), 360.0 * randf(), 360.0 * randf())
	print("Rotation direction is " + str(rotDirection))

func _process(delta: float) -> void:
	elapsedTime += delta
	var decPart = elapsedTime - int(elapsedTime)
	rotate(rotDirection.lerp(rotDirection2, decPart).normalized(), rotSpeed)
