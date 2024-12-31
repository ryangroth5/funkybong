extends CharacterBody2D

@export var speed: float = 300.0
@export var wander_range: float = 0.5
@export var wander_interval: float = 1.0
@export var acceleration: float = 2.0 # How quickly it changes speed
@export var min_speed: float = 150.0
@export var max_speed: float = 300.0

var direction: Vector2 = Vector2.RIGHT
var wander_timer: float = 0.0
var target_speed: float

func _ready() -> void:
	direction = Vector2.RIGHT.rotated(randf() * 2 * PI)
	target_speed = speed
	velocity = direction * speed

func _physics_process(delta: float) -> void:
	wander_timer += delta
	
	if wander_timer >= wander_interval:
		wander_timer = 0.0
		direction = direction.rotated(randf_range(-wander_range, wander_range))
		# Randomly change target speed
		target_speed = randf_range(min_speed, max_speed)
	
	# Smoothly adjust current speed to target speed
	speed = lerp(speed, target_speed, delta * acceleration)
	velocity = direction * speed
	
	var collision = move_and_slide()
	
	if get_slide_collision_count() > 0:
		var collision_info = get_slide_collision(0)
		var bounce_direction = direction.bounce(collision_info.get_normal())
		bounce_direction = bounce_direction.rotated(randf_range(-PI / 4, PI / 4))
		direction = bounce_direction.normalized()
		velocity = direction * speed
		# Optional: Slow down a bit on collision
		target_speed = min_speed
	
	# Smooth rotation
	var rotation_speed = 10.0
	var target_rotation = velocity.angle()
	rotation = lerp_angle(rotation, target_rotation, delta * rotation_speed)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
