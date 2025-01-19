class_name SkeletonMob
extends CharacterBody2D

@export var speed: float = 300.0
@export var detection_radius: float = 200.0
@export var attack_range: float = 50.0

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var nav_agent = $NavigationHelper as NagivationHelper
@export var hit_points = 20;
@onready var over_animation_player = $OverAnimationPlayer;


enum SkeletonState {TO_PLAYER, TO_SINK}
@export var current_state: SkeletonState = SkeletonState.TO_SINK

var is_attacking: bool = false
var current_player: Node2D = null

func _ready() -> void:
	animation_tree.set("parameters/playback", "idle") # Replace 'idle' with your default state
	animation_tree.active = true
	add_to_group("DespawnableMobsGroup")

func set_state(new_state: SkeletonState) -> void:
	current_state = new_state

func _physics_process(delta: float) -> void:
	if is_attacking:
		return
	
	# Cache players array lookup
	if current_state == SkeletonState.TO_SINK or current_player == null:
		current_player = find_closest_player(get_tree().get_nodes_in_group("PlayersGroup"))
	
	if current_player:
		set_state(SkeletonState.TO_PLAYER)
		nav_agent.set_target_position(current_player.global_position)
	
	if !nav_agent.get_is_active():
		state_machine.travel("idle")
		if !current_player:
			find_and_set_random_sink()
		return
	
	velocity = nav_agent.process_navigation(delta, speed, 0)
	# Only update animations if there's actual movement
	if velocity != Vector2.ZERO:
		update_animations(velocity)
		state_machine.travel("walk")
	else:
		state_machine.travel("idle")
	
	move_and_slide()
	
	# Check attack condition only if we have a player and are in attack range
	if current_player and global_position.distance_to(current_player.global_position) < attack_range:
		start_attack()

func update_animations(v: Vector2) -> void:
	var nodes = ["walk", "idle", "attack"]
	for node in nodes:
		animation_tree.set("parameters/%s/blend_position" % node, v)

func find_closest_player(players: Array) -> Node2D:
	var closest_player: Node2D = null
	var closest_distance: float = detection_radius
	
	for player in players:
		var distance = global_position.distance_squared_to(player.global_position)
		# Use distance_squared_to instead of distance_to to avoid square root calculation
		if distance < closest_distance * closest_distance:
			closest_distance = sqrt(distance) # Only calculate square root once when needed
			closest_player = player
	
	return closest_player

func start_attack() -> void:
	if is_attacking:
		return
	
	is_attacking = true
	state_machine.travel("attack")
	await get_tree().create_timer(1.0).timeout
	is_attacking = false

func find_and_set_random_sink() -> void:
	nav_agent.find_and_set_random_sink()

func _on_navigation_helper_navigation_finished() -> void:
	set_state(SkeletonState.TO_SINK)


func take_damage(amount: int) -> void:
	if hit_points <= 0: # Early return if already defeated
		return
		
	over_animation_player.play("hit")
	hit_points -= amount
	
	if hit_points <= 0:
		_spawn_explosion()
		queue_free();

func _spawn_explosion() -> void:
	var mob_scene := preload("res://logic/explosion/explosion.tscn") # Use preload instead of load
	var mob := mob_scene.instantiate()
	mob.animation_root = "skeleton"
	mob.position = position
	get_parent().call_deferred("add_child", mob) # Use call_deferred for safer node addition
