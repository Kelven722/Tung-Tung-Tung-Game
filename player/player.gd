extends CharacterBody3D

const WALK_SPEED = 3.0
const CROUCH_SPEED = 1.5
const JUMP_VELOCITY = 4.0

const STAND_HEIGHT = 2.0
const CROUCH_HEIGHT = 0.85

var crouching = false

@onready var camera = $head/Camera3D
@onready var collision_shape = $CollisionShape3D


func _physics_process(delta: float) -> void:

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not crouching:
		velocity.y = JUMP_VELOCITY

	# Crouch toggle
	if Input.is_action_just_pressed("crouch"):
		crouching = !crouching

	# Movement speed
	var speed = CROUCH_SPEED if crouching else WALK_SPEED

	# Smooth crouch animation
	var target_height = CROUCH_HEIGHT if crouching else STAND_HEIGHT

	collision_shape.shape.height = lerp(
		collision_shape.shape.height,
		target_height,
		10.0 * delta
	)

	# Camera-relative movement
	var input_dir = Input.get_vector(
		"left","right","forward","backward")
	var camera_basis = camera.global_transform.basis
	var direction = camera_basis * Vector3(input_dir.x,0,input_dir.y)

	# Ignore vertical camera rotation
	direction.y = 0
	direction = direction.normalized()

	# Apply movement
	if direction.length() > 0:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Move player
	move_and_slide()
