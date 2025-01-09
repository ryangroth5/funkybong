class_name SkeletonMob
extends CharacterBody2D

@export var speed: float = 300.0
@export var detection_radius: float = 200.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var nav_agent = $NavigationHelper as NagivationHelper;


enum SkeletonState {
	TO_PLAYER,
	TO_SINK
}
@export var current_state: SkeletonState = SkeletonState.TO_SINK;


var target_position: Vector2
var is_attacking: bool = false
var current_player: Node2D = null

func _ready() -> void:
	animation_tree.active = true
	add_to_group("DespawnableMobsGroup")

func set_state(new_state: SkeletonState) -> void:
	current_state = new_state;


func _physics_process(delta: float) -> void:
	if is_attacking:
		return
		
	# Check for nearby players
	var players = get_tree().get_nodes_in_group("PlayersGroup")
	current_player = find_closest_player(players)
	
	if current_player:
		set_state(SkeletonState.TO_PLAYER)
		# Player is within range, chase them
		nav_agent.set_target_position(current_player.global_position);
	
	if !nav_agent.get_is_active():
		# We've reached our destination
		state_machine.travel("idle")
		if !current_player:
			# If we're not chasing a player, find a new sink
			find_and_set_random_sink()
		return
	
	
	velocity = nav_agent.process_navigation(delta, speed, 0)
	update_animations(velocity)
	move_and_slide()
	
	# Update animations
	if velocity != Vector2.ZERO:
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
	
	# Check if close enough to player to attack
	if current_player and global_position.distance_to(current_player.global_position) < 50:
		start_attack()

func update_animations(v: Vector2) -> void:
	animation_tree.set("parameters/walk/blend_position", v)
	animation_tree.set("parameters/idle/blend_position", v)
	animation_tree.set("parameters/attack/blend_position", v)
	

func find_closest_player(players: Array) -> Node2D:
	var closest_player: Node2D = null
	var closest_distance: float = detection_radius
	
	for player in players:
		var distance = global_position.distance_to(player.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_player = player
	
	return closest_player

func start_attack() -> void:
	if is_attacking:
		return
		
	is_attacking = true
	state_machine.travel("attack")
	# Adjust timeout based on your attack animation length
	await get_tree().create_timer(1.0).timeout
	is_attacking = false

# This function should be implemented to find a random sink in your level
func find_and_set_random_sink() -> void:
	nav_agent.find_and_set_random_sink()


func _on_navigation_helper_navigation_finished() -> void:
	set_state(SkeletonState.TO_SINK);
