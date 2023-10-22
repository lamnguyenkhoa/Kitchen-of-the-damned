extends CharacterBody3D
class_name Monster

@export var monster_name: String

const SPEED = 100.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	# Make sure to not await during _ready.
	call_deferred("actor_setup")


func _physics_process(delta):
	chase(delta)

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	# Now that the navigation map is no longer empty, set the movement target.
	navigation_agent.set_target_position(GameManager.player.global_position)


func chase(delta: float):
	if navigation_agent.is_navigation_finished():
		return

	navigation_agent.set_target_position(GameManager.player.global_position)
	var new_velocity = (navigation_agent.get_next_path_position() - global_position).normalized() * SPEED * delta
	velocity = new_velocity
	move_and_slide()