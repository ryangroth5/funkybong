extends CharacterBody2D

@export var speed: float = 300.0
var direction: Vector2 = Vector2.RIGHT # Declare the direction variable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Start in a random direction
	direction = Vector2.RIGHT.rotated(randf() * 2 * PI)
	velocity = direction * speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# Move and detect collisions
	move_and_slide()
	
	# If we hit something, bounce
	if get_slide_collision_count() > 0:
		var collision_info = get_slide_collision(0)
		direction = direction.bounce(collision_info.get_normal())
		velocity = direction * speed

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
