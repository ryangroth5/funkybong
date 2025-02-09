class_name PropThrower
extends Node2D

signal throw_started
signal throw_completed

@export var prop_holder:PropHolder =  owner
@export var auto_throw: bool = false
@export var target: Node2D = null
@export var throw_delay: float = 0.0

# Optional animation tree reference for visual feedback
#@export var animation_tree: AnimationTree = null
#@export var throw_animation_name: String = "throw"

func _ready() -> void:
	if prop_holder:
		prop_holder.prop_picked_up.connect(_on_prop_picked_up)

func _on_prop_picked_up(_prop: RigidBody2D) -> void:
	if auto_throw and target:
		throw_at_target()

func throw_at_target() -> void:
	if !prop_holder or !prop_holder.has_prop():
		return
	
	throw_started.emit()
	
#	if animation_tree and !throw_animation_name.is_empty():
#		var state_machine = animation_tree.get("parameters/playback")
#		state_machine.travel(throw_animation_name)
	
	if throw_delay > 0:
		await get_tree().create_timer(throw_delay).timeout
	
	if target and prop_holder.has_prop():
		var throw_direction = (target.global_position - global_position).normalized()
		prop_holder.throw_prop(throw_direction)
		throw_completed.emit()

func throw_in_direction(direction: Vector2) -> void:
	if !prop_holder or !prop_holder.has_prop():
		return
	
	throw_started.emit()
	
#	if animation_tree and !throw_animation_name.is_empty():
#		var state_machine = animation_tree.get("parameters/playback")
#		state_machine.travel(throw_animation_name)
	
	if throw_delay > 0:
		await get_tree().create_timer(throw_delay).timeout
	
	if prop_holder.has_prop():
		prop_holder.throw_prop(direction)
		throw_completed.emit()
