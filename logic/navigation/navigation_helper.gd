class_name NagivationHelper
extends Node2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

signal navigation_finished
signal velocity_computed

var parent: Node2D
var target_position: Vector2
var is_active: bool = false

func _ready()->void:
	parent = get_parent();	

func get_is_active()->bool:
	return is_active;

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
	
# sort of does the follow the path navigation stuff, use during physics process
func process_navigation(_delta: float, speed: float, _acceleration: float) -> Vector2:
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

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity_computed.emit(safe_velocity);

func set_target_position(pos: Vector2) -> void:
	nav_agent.target_position = pos;
	is_active = true;
	target_position = pos

func get_target_position()->Vector2:
	return target_position



func find_and_set_random_sink() -> bool:
	var sinks = get_tree().get_nodes_in_group("MobSinksGroup")
	if sinks.size() > 0:
		# Pick a random sink from the group
		var random_sink = sinks[randi() % sinks.size()]
		# Set the target position to the sink's position
		set_target_position(random_sink.global_position)
		return true;
	else:
		printerr("Mob looking for a sink but no sink found.")
		return false;
		# If no sinks found, reset wander timer and continue wandering
