extends CharacterBody2D

@export var speed: float = 300.0
@export var detection_radius: float = 200.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var target_position: Vector2
var is_attacking: bool = false
var current_player: Node2D = null

func _ready() -> void:
	animation_tree.active = true
	find_and_set_random_sink()

func _physics_process(delta: float) -> void:
	if is_attacking:
		return
		
	# Check for nearby players
	var players = get_tree().get_nodes_in_group("PlayersGroup")
	current_player = find_closest_player(players)
	
	if current_player:
		# Player is within range, chase them
		nav_agent.target_position = current_player.global_position
	
	if nav_agent.is_navigation_finished():
		# We've reached our destination
		state_machine.travel("idle")
		if !current_player:
			# If we're not chasing a player, find a new sink
			find_and_set_random_sink()
		return
	
	# Move towards target
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction: Vector2 = global_position.direction_to(next_path_position)
	
	velocity = direction * speed
	move_and_slide()
	
	# Update animations
	if velocity != Vector2.ZERO:
		animation_tree.set("parameters/walk/blend_position", direction)
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
	
	# Check if close enough to player to attack
	if current_player and global_position.distance_to(current_player.global_position) < 50:
		start_attack()

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
	var sinks = get_tree().get_nodes_in_group("Sinks") # Assuming sinks are in a group
	if sinks.size() > 0:
		var random_sink = sinks[randi() % sinks.size()]
		nav_agent.target_position = random_sink.global_position
