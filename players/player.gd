class_name Player
extends CharacterBody2D
signal hit
@export var controller_number = 0;
@export var speed = 400
#** keeps track of if the player is allowed to enter the game, PlayerHud manages this.
@export var can_enter = false;
var screen_size
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
# keep the last direction the controller moved in.
var last_input_vector: Vector2 = Vector2.ZERO
var input_vector: Vector2 = Vector2.ZERO
var is_attacking = false

signal health_changed(new_health: int)
signal player_died()
signal player_wants_to_enter(player: Player)

@export var health = 100

func set_controller(index) -> void:
	controller_number = index;

func get_controller_action(action: String) -> String:
	return "c" + str(controller_number) + "_" + action;


func end():
	can_enter = false;
	hide();
	$CollisionShape2D.disabled = true;
	position = Vector2.INF

func start(pos: Vector2):
	if (can_enter):
		can_enter = false;
		position = pos;
		show();
		$CollisionShape2D.disabled = false;
		$StartStream.playing = true;

func _ready() -> void:
	add_to_group("PlayersGroup")
	hide();
	animation_tree.active = true
	
func _physics_process(_delta: float) -> void:
	# Handle movement physics
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * speed
	else:
		velocity = Vector2.ZERO
			
	move_and_slide()

func wants_to_enter() -> void:
	if (can_enter):
		player_wants_to_enter.emit(self)
	

func coin_up() -> void:
	health += GlobalConstants.COIN_UP_HEALTH;
	health_changed.emit(health)
	$CoinUpStream.playing = true;

func _process(_delta: float) -> void:
	# Handle animations and input for actions
	input_vector = get_input_vector()
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
		await get_tree().create_timer(GlobalConstants.ATTACK_SPEED).timeout
		is_attacking = false


	if Input.is_action_just_pressed(get_controller_action("coin")):
		coin_up()
	
	if Input.is_action_just_pressed(get_controller_action("start")):
		wants_to_enter()
	

func get_input_vector() -> Vector2:
	var measured_input_vector = Vector2.ZERO
	if Input.is_action_pressed(get_controller_action("right")):
		measured_input_vector.x += 1
	if Input.is_action_pressed(get_controller_action("left")):
		measured_input_vector.x -= 1
	if Input.is_action_pressed(get_controller_action("down")):
		measured_input_vector.y += 1
	if Input.is_action_pressed(get_controller_action("up")):
		measured_input_vector.y -= 1
	return measured_input_vector


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

func take_damage(amount: int) -> void:
	health -= amount;
	if (health < 0):
		player_died.emit()
	else:
		health_changed.emit(health)
