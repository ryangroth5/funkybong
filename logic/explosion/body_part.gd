extends RigidBody2D
@export var animation = "skeleton_head"
@export var initial_orientation: float = -1 # -1 means random
@export var initial_force: float = 300.0
@export var initial_torque: float = 5.0
@export var max_height: float = 100.0
@export var effect_duration: float = 2.0
@export var scale_duration: float = -1.0 # -1 means use default (80% of effect_duration)

var current_time: float = 0.0
var virtual_z: float = 0.0
var initial_pos: Vector2
var sprite: AnimatedSprite2D
var actual_scale_duration: float

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
	
	# Set up initial physics
	if initial_orientation < 0:
		rotation = randf() * TAU # Random rotation between 0 and 2π
	else:
		rotation = initial_orientation
	
	# Apply random initial force and torque for top-down explosion effect
	var force_direction = Vector2.RIGHT.rotated(randf() * TAU)
	apply_central_impulse(force_direction * initial_force)
	apply_torque_impulse((randf() * 2 - 1) * initial_torque)

func _physics_process(delta: float) -> void:
	current_time += delta
	
	# Calculate scale based on time (simulates height in top-down view)
	var scale_factor = 1.0
	if current_time <= actual_scale_duration:
		var time_factor = current_time / actual_scale_duration
		# Smooth parabolic curve that starts and ends at 1.0
		scale_factor = 1.0 + (sin(time_factor * PI) * 0.25) # Reduced scale variation for top-down
	
	scale = Vector2.ONE * scale_factor
	
	# Update sprite frame based on rotation
	var rotation_normalized = fmod(rotation, TAU) / TAU # Convert rotation to 0-1 range
	var frame = int(rotation_normalized * 8) % 8 # Convert to 8 direction frames
	sprite.frame = frame
	
	# Optional: fade out near the end of the effect
	if current_time >= effect_duration:
		queue_free() # Remove the node when the effect is complete
