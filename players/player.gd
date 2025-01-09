class_name Player
extends CharacterBody2D
signal hit
@export var controllerNumber = 0;
@export var speed = 400
var screen_size
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
# keep the last direction the controller moved in.
var last_input_vector = Vector2.ZERO
var is_attacking = false


func set_controller(index) -> void:
	controllerNumber = index;

func get_controller_action(action: String) -> String:
	return "c" + str(controllerNumber) + "_" + action;


func start(pos: Vector2):
	position = pos;
	show();
	$CollisionShape2D.disabled = false;

func _ready() -> void:
	add_to_group("PlayersGroup")
	hide();
	animation_tree.active = true
	
func _physics_process(_delta:float) -> void:
	# Handle movement physics
	if !is_attacking:
		var input_vector = get_input_vector()
		
		if input_vector != Vector2.ZERO:
			velocity = input_vector.normalized() * speed
		else:
			velocity = Vector2.ZERO
			
	move_and_slide()

func _process(_delta:float) -> void:
	# Handle animations and input for actions
	var input_vector = get_input_vector()
	if !is_attacking:
		if input_vector != Vector2.ZERO:
			# Update animation tree blend position
			update_animation_parameters(input_vector);
			last_input_vector = input_vector;
			state_machine.travel("walk")
		else:
			update_animation_parameters(last_input_vector)
			state_machine.travel("idle")
			
	# Handle attack input
	if Input.is_action_just_pressed(get_controller_action("attack")) and !is_attacking:
		is_attacking = true
		state_machine.travel("attack")
		await get_tree().create_timer(0.5).timeout
		is_attacking = false
	

func get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed(get_controller_action("right")):
		input_vector.x += 1
	if Input.is_action_pressed(get_controller_action("left")):
		input_vector.x -= 1
	if Input.is_action_pressed(get_controller_action("down")):
		input_vector.y += 1
	if Input.is_action_pressed(get_controller_action("up")):
		input_vector.y -= 1
	return input_vector


func _on_body_entered(_body: Node2D) -> void:
	hide();
	hit.emit();
	$CollisionShape2D.set_deferred("disabled", true)


# When player needs to be removed
func _exit_tree() -> void:
	remove_from_group("PlayersGroup")


func update_animation_parameters(input: Vector2) -> void:
	animation_tree["parameters/attack/blend_position"] = input;
	animation_tree["parameters/idle/blend_position"] = input;
	animation_tree["parameters/walk/blend_position"] = input;
