class_name Player
extends CharacterBody2D
@export var controller_number = 0;
@export var speed = 400
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
# keep the last direction the controller moved in.
var last_input_vector: Vector2 = Vector2.ZERO
var input_vector: Vector2 = Vector2.ZERO
var holding: PackedScene = null;

var player_state: PlayerStateEnum = PlayerStateEnum.SPAWNED
enum PlayerStateEnum {
	SPAWNED,
	COIN_UP,
	READY_TO_ENTER,
	PLAYING,
	ATTACKING,
	DEAD,
	CONTINUING,
	EXITING
}


signal health_changed(new_health: int)
signal player_died()
signal player_wants_to_enter(player: Player)
signal hit
signal current_prop_changed(prop: PackedScene)

@export var health = 100

func can_enter() -> bool:
	return (player_state == PlayerStateEnum.COIN_UP || player_state == PlayerStateEnum.READY_TO_ENTER);
		

func set_controller(index) -> void:
	controller_number = index;

func get_controller_action(action: String) -> String:
	return "c" + str(controller_number) + "_" + action;

func coined_up():
	hide();

func transition_state(ps: PlayerStateEnum) -> void:
	match ps:
		PlayerStateEnum.COIN_UP:
			if player_state != PlayerStateEnum.SPAWNED:
				print("cannot transition to coin up from %s " % ps)
				return
			coined_up();
			
			
	print("old state %d and new state %d" % [player_state, ps])
	player_state = ps;

func end():
	transition_state(PlayerStateEnum.CONTINUING)
	hide();
	$CollisionShape2D.disabled = true;
	position = Vector2.INF


# player can move. 
func start(pos: Vector2):
	if (can_enter()):
		transition_state(PlayerStateEnum.PLAYING)
		# empty weapon to start with
		$MeleeWeapon.remove_weapon()
		position = pos;
		show();
		$CollisionShape2D.disabled = false;
		$StartStream.playing = true;

func _ready() -> void:
	add_to_group("PlayersGroup")
	transition_state(PlayerStateEnum.SPAWNED)
	hide();
	animation_tree.active = true

	var scene = preload("res://objects/weapon/FistsWeapon.tscn")
	$MeleeWeapon.default_weapon_scene = scene;
	$MeleeWeapon.load_weapon(scene);
	# work with the prop holder
	var largest_dimension = ShapeUtils.get_collision_shape_largest_dimension($CollisionShape2D)
	$PropHolder.pickup_radius = largest_dimension
	$PropHolder.equipped.connect(picked_up_prop);
	$PropHolder.enabled = true;

func picked_up_prop(prop: PackedScene) -> void:
	if (prop != null):
		holding = prop
		if (prop.has_method("is_melee_weapon") && prop.is_melee_weapon()):
			$MeleeWeapon.load_weapon(prop)
			$PropHolder.hide_prop()
		else:
			$PropHolder.show_prop()
	
	current_prop_changed.emit(prop)


func _physics_process(_delta: float) -> void:
	# Handle movement physics
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()


func wants_to_enter() -> void:
	if (can_enter()):
		player_wants_to_enter.emit(self)
	

func is_attacking() -> bool:
	return player_state == PlayerStateEnum.ATTACKING

func can_move() -> bool:
	return player_state in [PlayerStateEnum.PLAYING, PlayerStateEnum.ATTACKING]

func coin_up() -> void:
	health += GlobalConstants.COIN_UP_HEALTH;
	health_changed.emit(health)
	$CoinUpStream.playing = true;
	transition_state(PlayerStateEnum.COIN_UP)

func _process(_delta: float) -> void:
	# Handle animations and input for actions
	if (can_move()):
		input_vector = get_input_vector()
		if !is_attacking():
			if input_vector != Vector2.ZERO:
				# Update animation tree blend position
				update_animation_parameters(input_vector);
				last_input_vector = input_vector;
				state_machine.travel("walk")
			else:
				update_animation_parameters(last_input_vector)
				state_machine.travel("idle")
				
		# Handle attack input
		if Input.is_action_just_pressed(get_controller_action("attack")) and !is_attacking():
			transition_state(PlayerStateEnum.ATTACKING)
			state_machine.travel("attack")
			await get_tree().create_timer(GlobalConstants.ATTACK_SPEED).timeout
			transition_state(PlayerStateEnum.PLAYING)

		if Input.is_action_just_pressed(get_controller_action("attack")) and !is_attacking():
			pass ;
			#$PropHolder.throw_prop(input_vector)


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


# called by a weapon to inflict damage to the player
func take_damage(amount: int) -> void:
	health -= amount;
	if (health < 0):
		player_died.emit()
	else:
		health_changed.emit(health)
