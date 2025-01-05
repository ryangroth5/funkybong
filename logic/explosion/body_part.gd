extends RigidBody2D
@export var animation = "skeleton_head"
@export var initial_orientation: float = -1 # -1 means random
@export var initial_force: float = 300.0
@export var initial_torque: float = 5.0
@export var max_height: float = 100.0
@export var effect_duration: float = 2.0
@export var scale_duration: float = -1.0 # -1 means use default (80% of effect_duration)
@export var bounce_count: int = 2 # Number of bounces before settling
@export var bounce_factor: float = 0.6 # How much energy is retained in each bounce
@export var wall_bounce_factor: float = 0.7 # How much energy is retained in wall bounces

var current_time: float = 0.0
var virtual_z: float = 0.0
var initial_pos: Vector2
var sprite: AnimatedSprite2D
var actual_scale_duration: float
var current_bounce: int = 0
var is_bouncing: bool = false
var bounce_time: float = 0.0
var last_bounce_height: float = 0.0
var bounce_duration: float = 0.5 # Duration of each bounce
var target_rotation: float = 0.0

func _ready() -> void:
	sprite = $AnimatedSprite2D
	sprite.play(animation)
	initial_pos = position
	
	# Set the actual scale duration
	actual_scale_duration = scale_duration if scale_duration > 0 else effect_duration * 0.8
	
	# Configure physics for top-down
	gravity_scale = 0 # Disable gravity
	linear_damp = 1.0 # Add some drag to slow down over time
	angular_damp = 1.0 # Add some rotational drag
	wall_bounce_factor = 0.7 # Add bounce factor for physics engine
	
	# Enable contact monitoring for collision detection
	contact_monitor = true
	max_contacts_reported = 4
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Set up initial physics
	if initial_orientation < 0:
		rotation = randf() * TAU # Random rotation between 0 and 2π
	else:
		rotation = initial_orientation
	
	# Apply random initial force and torque for top-down explosion effect
	var force_direction = Vector2.RIGHT.rotated(randf() * TAU)
	apply_central_impulse(force_direction * initial_force)
	apply_torque_impulse((randf() * 2 - 1) * initial_torque)


func update_scale(delta: float) -> void:
	var target_scale_factor = 1.0
	if current_bounce < bounce_count:
		var bounce_height = max_height * pow(bounce_factor, current_bounce)
		var t = bounce_time / bounce_duration
		var bounce_scale = sin(t * PI) * bounce_height / max_height
		target_scale_factor = 1.0 + bounce_scale * 0.25
	
	# Smoothly interpolate to target scale
	scale = scale.lerp(Vector2.ONE * target_scale_factor, delta * 10.0)

func _process(delta: float) -> void:
	# Handle visual updates here
	var rotation_normalized = fmod(rotation, TAU) / TAU
	var frame = int(rotation_normalized * 8) % 8
	sprite.frame = frame
	rotation = lerp_angle(rotation, target_rotation, delta * 10.0)
	# Handle scale updates
	update_scale(delta)

func _physics_process(delta: float) -> void:
	current_time += delta
	
	# Handle bouncing scale effect
	var scale_factor = 1.0
	if current_bounce < bounce_count:
		bounce_time += delta
		var bounce_height = max_height * pow(bounce_factor, current_bounce)
		
		if bounce_time >= bounce_duration:
			bounce_time = 0
			current_bounce += 1
			# Apply upward force for next bounce if we're still bouncing
			if current_bounce < bounce_count:
				last_bounce_height = bounce_height * bounce_factor
		
		# Calculate bounce scale
		var t = bounce_time / bounce_duration
		var bounce_scale = sin(t * PI) * bounce_height / max_height
		scale_factor = 1.0 + bounce_scale * 0.25
	else:
		# Normal scale animation when not bouncing
		if current_time <= actual_scale_duration:
			var time_factor = current_time / actual_scale_duration
			scale_factor = 1.0 + (sin(time_factor * PI) * 0.25)
	
	scale = Vector2.ONE * scale_factor
	
	# Update sprite rotation based on both physics rotation and velocity
	var velocity_angle = linear_velocity.angle()
	var blend_factor = clamp(linear_velocity.length() / initial_force, 0, 1)
	target_rotation = lerp_angle(rotation, velocity_angle, blend_factor)
	
	# Update sprite frame based on rotation
	#var rotation_normalized = fmod(final_rotation, TAU) / TAU
	#var frame = int(rotation_normalized * 8) % 8
	#sprite.frame = frame
	
	# Optional: fade out near the end of the effect
	if current_time >= effect_duration:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# For RigidBody2D, we need to enable contact_monitor and set contacts_reported
	# This should be done in _ready():
	# contact_monitor = true
	# contacts_reported = 4
	
	# Get collision normal from the current collision
	var collision_normal = (position - body.position).normalized()
	
	if collision_normal != Vector2.ZERO:
		# Calculate reflection vector
		var velocity = linear_velocity
		var reflection = velocity.bounce(collision_normal)
		
		# Apply wall bounce
		linear_velocity = reflection * wall_bounce_factor
		
		# Add some random rotation on collision
		apply_torque_impulse((randf() * 2 - 1) * initial_torque * 0.5)
		
		# Start bounce animation if hitting floor-like surface
		if collision_normal.dot(Vector2.UP) > 0.7 and current_bounce < bounce_count:
			bounce_time = 0
			is_bouncing = true


func lerp_angle(from: float, to: float, weight: float) -> float:
	var difference = fmod(to - from, TAU)
	var distance = fmod(2.0 * difference, TAU) - difference
	return from + distance * weight
