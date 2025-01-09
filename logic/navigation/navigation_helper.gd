class_name NagivationHelper
extends Node
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

signal navigation_finished

#var nav_agent: NavigationAgent2D
var parent: Node2D
var target_position: Vector2
var is_active: bool = false

func _init(parent_node: Node2D, navigation_agent: NavigationAgent2D) -> void:
	parent = parent_node
#	nav_agent = navigation_agent
	
	# Configure the NavigationAgent2D
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0

func start_navigation_to_position(pos: Vector2) -> void:
	target_position = pos
	nav_agent.target_position = pos
	is_active = true

func start_navigation_to_random_group_member(group_name: String) -> bool:
	var targets = parent.get_tree().get_nodes_in_group(group_name)
	if targets.size() > 0:
		var random_target = targets[randi() % targets.size()]
		start_navigation_to_position(random_target.global_position)
		return true
	return false

func process_navigation(delta: float, speed: float, acceleration: float) -> Vector2:
	if not is_active:
		return Vector2.ZERO
		
	if nav_agent.is_navigation_finished():
		is_active = false
		navigation_finished.emit()
		return Vector2.ZERO
		
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var direction = (next_path_position - parent.global_position).normalized()
	var velocity = direction * speed
	nav_agent.set_velocity(velocity)
	return velocity

func is_navigation_finished() -> bool:
	return nav_agent.is_navigation_finished()

func stop_navigation() -> void:
	is_active = false
