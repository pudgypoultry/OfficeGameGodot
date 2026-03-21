extends State

@export var movement_speed : float = 5.0
@export var mouse_sensitivity : float = 0.05
@export var rotation_bounds : float = 80.0
@export var deceleration : float = 35.0


func enter_state(last_state : State):
	super(last_state)


func state_physics_process(delta : float) -> void:
	super(delta)
	movement_behavior(delta)


func state_unhandled_input(event : InputEvent):
	super(event)
	rotation_behavior(event)


func movement_behavior(delta : float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (actor_reference.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = Vector3(direction.x, 0, direction.z).normalized()
	if direction:
		actor_reference.velocity.x = direction.x * movement_speed
		actor_reference.velocity.z = direction.z * movement_speed
	else:
		actor_reference.velocity.x = move_toward(actor_reference.velocity.x, 0, delta * deceleration)
		actor_reference.velocity.z = move_toward(actor_reference.velocity.z, 0, delta * deceleration)
	
	if not actor_reference.is_on_floor():
		actor_reference.velocity += actor_reference.get_gravity() * delta
	
	actor_reference.move_and_slide()


func rotation_behavior(event : InputEvent):
	if event is InputEventMouseMotion:
		actor_reference.rotate_y(-event.relative.x * mouse_sensitivity)
		actor_reference.rotation.x += -event.relative.y * mouse_sensitivity
		actor_reference.rotation.x = clampf(actor_reference.rotation.x, deg_to_rad(-rotation_bounds), deg_to_rad(rotation_bounds))
