extends CharacterBody3D
class_name FPSPlayer

@onready var aim_ray: RayCast3D = $Head/Camera3d/RayCast3d
@onready var camera: Camera3D = $Head/Camera3d
@onready var hold_pos: Marker3D = $Head/Camera3d/HoldPos
@onready var inspect_pos: Marker3D = $Head/Camera3d/InspectPos
@onready var item_holder = $Head/Camera3d/ItemHolder


var mouse_sensibility = 1500
var mouse_relative_x = 0
var mouse_relative_y = 0
var is_inspecting = false
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	aim_ray.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("inspect_item"):
		var tween = get_tree().create_tween()
		if not is_inspecting:
			is_inspecting = true
			tween.tween_property(item_holder, "position", inspect_pos.position, 0.25)
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED
		else:
			is_inspecting = false
			tween.tween_property(item_holder, "position", hold_pos.position, 0.25)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion and not is_inspecting:
		rotation.y -= event.relative.x / mouse_sensibility
		camera.rotation.x -= event.relative.y / mouse_sensibility
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
