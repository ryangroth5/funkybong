extends CharacterBody2D
signal hit

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


func start(pos):
	print("Player starting at position: ", pos) # Basic logging
	position = pos;
	show();
	$CollisionShape2D.disabled = false;

func _ready() -> void:
	hide();
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO

	# Only process movement if not attacking
	if !is_attacking:
		# Input handling
		if Input.is_action_pressed("right"):
			velocity.x += 1
		if Input.is_action_pressed("left"):
			velocity.x -= 1
		if Input.is_action_pressed("down"):
			velocity.y += 1
		if Input.is_action_pressed("up"):
			velocity.y -= 1

		# Update facing only if we're moving
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
			update_facing(velocity)
			is_idle = false
			idle_timer = 0.0
			update_movement_animation()
		else:
			idle_timer += delta
			if idle_timer >= 1.0 and !is_idle:
				is_idle = true
				play_idle_animation()
			elif !is_idle:
				$AnimatedSprite2D.stop()

		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)
		move_and_slide()

	# Handle attack input regardless of movement state
	if Input.is_action_just_pressed("attack") and !is_attacking:
		play_attack_animation(velocity)
		
	#print("Player initialized with states - idle: ", is_idle,
	#	", attacking: ", is_attacking,
	#	", facing: ", facing)

# Update facing based on velocity
func update_facing(velocity: Vector2) -> void:
	facing = {
		"east": velocity.x > 0,
		"west": velocity.x < 0,
		"north": velocity.y < 0,
		"south": velocity.y > 0
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

func play_attack_animation(velocity) -> void:
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
