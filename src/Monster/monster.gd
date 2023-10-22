extends CharacterBody3D
class_name Monster

@export var monster_name: String
@export var move_speed: float

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

# func actor_setup():
# 	# Wait for the first physics frame so the NavigationServer can sync.
# 	await get_tree().physics_frame
# 	# Now that the navigation map is no longer empty, set the movement target.
# 	navigation_agent.set_target_position(GameManager.player.global_position)


# func chase(delta: float):
# 	if navigation_agent.is_navigation_finished():
# 		return

# 	navigation_agent.set_target_position(GameManager.player.global_position)
# 	var new_velocity = (navigation_agent.get_next_path_position() - global_position).normalized() * move_speed * delta
# 	velocity = new_velocity
# 	move_and_slide()