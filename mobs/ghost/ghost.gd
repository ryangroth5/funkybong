extends CharacterBody2D

enum GhostState {
	WANDER,
	CHASE,
	FLEE,
	NAVIGATE
}

@export var speed: float = 300.0
@export var wander_range: float = 0.5
@export var wander_interval: float = 1.0
@export var acceleration: float = 2.0
@export var min_speed: float = 150.0
@export var max_speed: float = 300.0
@export var max_wander_duration = 5.0 # 20 normally
var wander_duration_timer: float = 0
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D;

# State-specific variables
@export var current_state: GhostState = GhostState.WANDER
var target_position: Vector2
var player_ref: Node2D # Reference to player for chase/flee states

# Existing movement variables
var direction: Vector2 = Vector2.RIGHT
var wander_timer: float = 0.0
var target_speed: float

func _ready() -> void:
	direction = Vector2.RIGHT.rotated(randf() * 2 * PI)
	target_speed = speed
	velocity = direction * speed
	wander_duration_timer = 0;

	# Configure the NavigationAgent2D
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	add_to_group("DespawnableMobsGroup")

func _physics_process(delta: float) -> void:
	match current_state:
		GhostState.WANDER:
			process_wander_state(delta)
		GhostState.CHASE:
			process_chase_state(delta)
		GhostState.FLEE:
			process_flee_state(delta)
		GhostState.NAVIGATE:
			process_navigate_state(delta)
	
	move_and_slide()
	handle_collision()
	update_rotation(delta)

func process_wander_state(delta: float) -> void:
	wander_timer += delta
	wander_duration_timer += delta;
	
	if wander_timer >= wander_interval:
		wander_timer = 0.0
		direction = direction.rotated(randf_range(-wander_range, wander_range))
		target_speed = randf_range(min_speed, max_speed)
	
	# Check if it's time to switch to navigation
	if wander_duration_timer >= max_wander_duration:
		find_and_set_random_sink()

	speed = lerp(speed, target_speed, delta * acceleration)
	velocity = direction * speed

func find_and_set_random_sink() -> void:
	var sinks = get_tree().get_nodes_in_group("MobSinksGroup")
	if sinks.size() > 0:
		# Pick a random sink from the group
		var random_sink = sinks[randi() % sinks.size()]
		# Set the target position to the sink's position
		set_target_position(random_sink.global_position)
	else:
		printerr("Mob looking for a sink but no sink found.")
		# If no sinks found, reset wander timer and continue wandering
		wander_duration_timer = 0.0

func process_chase_state(delta: float) -> void:
	if player_ref:
		# Placeholder: Add chase logic here
		# Example: Move towards player position
		direction = (player_ref.global_position - global_position).normalized()
		target_speed = max_speed
		speed = lerp(speed, target_speed, delta * acceleration)
		velocity = direction * speed

# Optional: Add this if you want smoother navigation
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func process_flee_state(delta: float) -> void:
	if player_ref:
		# Placeholder: Add flee logic here
		# Example: Move away from player position
		direction = (global_position - player_ref.global_position).normalized()
		target_speed = max_speed
		speed = lerp(speed, target_speed, delta * acceleration)
		velocity = direction * speed


func process_navigate_state(delta: float) -> void:
	if not nav_agent.is_navigation_finished():
		# Get the next path position
		var next_path_position: Vector2 = nav_agent.get_next_path_position()
		
		# Calculate direction and movement
		direction = (next_path_position - global_position).normalized()
		target_speed = speed
		speed = lerp(speed, target_speed, delta * acceleration)
		velocity = direction * speed
		
		# Update the agent's velocity
		nav_agent.set_velocity(velocity)
	else:
		# We've reached the target, switch back to wandering
		set_state(GhostState.WANDER)

func handle_collision() -> void:
	if get_slide_collision_count() > 0:
		var collision_info = get_slide_collision(0)
		var bounce_direction = direction.bounce(collision_info.get_normal())
		bounce_direction = bounce_direction.rotated(randf_range(-PI / 4, PI / 4))
		direction = bounce_direction.normalized()
		velocity = direction * speed
		target_speed = min_speed

func update_rotation(delta: float) -> void:
	var rotation_speed = 10.0
	var target_rotation = velocity.angle()
	rotation = lerp_angle(rotation, target_rotation, delta * rotation_speed)

func set_state(new_state: GhostState) -> void:
	current_state = new_state
	# Reset relevant variables based on state
	match new_state:
		GhostState.WANDER:
			wander_timer = 0.0
		GhostState.CHASE:
			target_speed = max_speed
		GhostState.FLEE:
			target_speed = max_speed
		GhostState.NAVIGATE:
			pass

func set_target_position(pos: Vector2) -> void:
	nav_agent.target_position = pos;
	target_position = pos
	set_state(GhostState.NAVIGATE)

func set_player_reference(player: Node2D) -> void:
	player_ref = player

func start_chasing() -> void:
	set_state(GhostState.CHASE)

func start_fleeing() -> void:
	set_state(GhostState.FLEE)
