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

# State-specific variables
var current_state: GhostState = GhostState.WANDER
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
	
	if wander_timer >= wander_interval:
		wander_timer = 0.0
		direction = direction.rotated(randf_range(-wander_range, wander_range))
		target_speed = randf_range(min_speed, max_speed)
	
	speed = lerp(speed, target_speed, delta * acceleration)
	velocity = direction * speed

func process_chase_state(delta: float) -> void:
	if player_ref:
		# Placeholder: Add chase logic here
		# Example: Move towards player position
		direction = (player_ref.global_position - global_position).normalized()
		target_speed = max_speed
		speed = lerp(speed, target_speed, delta * acceleration)
		velocity = direction * speed

func process_flee_state(delta: float) -> void:
	if player_ref:
		# Placeholder: Add flee logic here
		# Example: Move away from player position
		direction = (global_position - player_ref.global_position).normalized()
		target_speed = max_speed
		speed = lerp(speed, target_speed, delta * acceleration)
		velocity = direction * speed

func process_navigate_state(delta: float) -> void:
	# Placeholder: Add navigation logic here
	# Example: Move towards target_position
	if target_position:
		direction = (target_position - global_position).normalized()
		target_speed = speed
		speed = lerp(speed, target_speed, delta * acceleration)
		velocity = direction * speed
		
		# Optional: Switch to wander when close to target
		if global_position.distance_to(target_position) < 10:
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
	target_position = pos
	set_state(GhostState.NAVIGATE)

func set_player_reference(player: Node2D) -> void:
	player_ref = player

func start_chasing() -> void:
	set_state(GhostState.CHASE)

func start_fleeing() -> void:
	set_state(GhostState.FLEE)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
