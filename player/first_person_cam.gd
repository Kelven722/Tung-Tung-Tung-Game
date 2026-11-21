extends Node3D

var sensitivity = 0.2
var can_look := true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$"../../flashlight".visible = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("flashlight"):
		$"../../flashlight".visible = !$"../../flashlight".visible
		$Camera3D/click_sound.play()


func _input(event: InputEvent) -> void:
	if !can_look:
		return

	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
