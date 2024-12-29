extends CharacterBody2D
signal hit
@export var controllerNumber = 0;
@export var speed = 400
var screen_size

# Character state
var facing = {
	"east": false,
	"west": false,
	"north": false,
	"south": true # Default facing south
}
var is_idle = false
var is_attacking = false
var idle_timer = 0.0
var west_horizontal_flip_modifier = true;

func set_controller(index) -> void:
	controllerNumber = index;

func get_controller_action(action: String) -> String:
	return "c" + str(controllerNumber) + "_" + action;


func start(pos: Vector2):
	print("Player starting at position: ", pos) # Basic logging
	position = pos;
	show();
	$CollisionShape2D.disabled = false;

func _ready() -> void:
	add_to_group("PlayersGroup")
	hide();
	

func _physics_process(delta: float) -> void:

	print("Player initialized with states - idle: ", is_idle,
		", attacking: ", is_attacking,
		", facing: ", facing,
		", delta: ", delta,
		", velocity: ", velocity)
	# Reset velocity at start of frame
	velocity = Vector2.ZERO

	# Only process movement if not attacking
	if !is_attacking:
		# Input handling
		var input_vector = Vector2.ZERO
		if Input.is_action_pressed(get_controller_action("right")):
			input_vector.x += 1
		if Input.is_action_pressed(get_controller_action("left")):
			input_vector.x -= 1
		if Input.is_action_pressed(get_controller_action("down")):
			input_vector.y += 1
		if Input.is_action_pressed(get_controller_action("up")):
			input_vector.y -= 1


			# Debug print for input
		if input_vector != Vector2.ZERO:
			print("Input vector: ", input_vector)

		# Update facing only if we're moving
		if input_vector != Vector2.ZERO:
			velocity = input_vector.normalized() * speed
			update_facing(velocity)
			is_idle = false
			idle_timer = 0.0
			update_movement_animation()
		else:
			$AnimatedSprite2D.stop()

		var collision = move_and_slide()
		if collision:
			for i in get_slide_collision_count():
				var collisionObj = get_slide_collision(i)
				print("I collided with ", collisionObj.get_collider().name)
			# Handle collision if needed
			pass

	# Update idle timer regardless of movement state
	if velocity == Vector2.ZERO:
		idle_timer += delta
		if idle_timer >= 1.0 and !is_idle:
			is_idle = true
			play_idle_animation()

	# Handle attack input regardless of movement state
	if Input.is_action_just_pressed(get_controller_action("attack")) and !is_attacking:
		play_attack_animation()
		

# Update facing based on velocity
func update_facing(newVelocity: Vector2) -> void:
	facing = {
		"east": newVelocity.x > 0,
		"west": newVelocity.x < 0,
		"north": newVelocity.y < 0,
		"south": newVelocity.y > 0
	}

func get_direction_suffix() -> String:
	for direction in facing.keys():
		if facing[direction]:
			return "_" + direction
	return "_south" # Default fallback

func play_animation(prefix: String) -> void:
	var anim_name = prefix + get_direction_suffix()
	$AnimatedSprite2D.animation = anim_name
	
	# Handle horizontal flip only for east/west animations
	if facing["west"]:
		$AnimatedSprite2D.flip_h = west_horizontal_flip_modifier
	else:
		$AnimatedSprite2D.flip_h = false
	
	$AnimatedSprite2D.play()

func update_movement_animation() -> void:
	play_animation("walk")

func play_idle_animation() -> void:
	play_animation("idle")

func play_attack_animation() -> void:
	is_attacking = true
	play_animation("attack")
	await $AnimatedSprite2D.animation_finished
	is_attacking = false
	
	# Return to appropriate state
	if velocity.length() == 0:
		if is_idle:
			play_idle_animation()
		else:
			$AnimatedSprite2D.stop()
	else:
		update_movement_animation()


func _on_body_entered(_body: Node2D) -> void:
	hide();
	hit.emit();
	$CollisionShape2D.set_deferred("disabled", true)


# When player needs to be removed
func _exit_tree() -> void:
	remove_from_group("PlayersGroup")
