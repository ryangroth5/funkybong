class_name PropHolder
extends Node2D

signal prop_picked_up(prop: RigidBody2D) # Signal now emits RigidBody2D prop
signal prop_thrown(prop: RigidBody2D) # Signal now emits RigidBody2D prop
signal equipped(prop: RigidBody2D) # Signal now emits RigidBody2D prop
signal unequipped(prop: RigidBody2D) # Signal now emits RigidBody2D prop

var _enabled = true;
@export var enabled: bool:
	set(value):
		$Area2D/CollisionShape2D.disabled = !value;
		_enabled = value;
	get():
		return _enabled;

@export var throw_force: float = 500.0
var _pickup_radius = 50.0;

@export var pickup_radius: float:
	set(value):
		set_pickup_radius(value);
	get():
		return _pickup_radius

func set_pickup_radius(value: float) -> void:
	_pickup_radius = value;
	$Area2D/CollisionShape2D.shape.radius = value


# Now held_prop is of type Prop (or subclass)
@export var held_prop: Prop = null
@onready var marker: Marker2D = $Marker2D
var current_prop_instance: RigidBody2D = null # Now directly store the RigidBody2D prop

# set the radius of effect to desired pickup radius
func _ready() -> void:
	$Area2D/CollisionShape2D.shape.radius = pickup_radius
	held_prop = null;

func show_prop():
	if !current_prop_instance: # Check if prop instance exists
		return
	current_prop_instance.visible = true

func hide_prop():
	if !current_prop_instance: # Check if prop instance exists
		return
	current_prop_instance.visible = false

func has_prop() -> bool:
	return held_prop != null

func which_prop() -> Prop: # Return Prop resource
	return held_prop

func can_pickup() -> bool:
	return enabled and held_prop == null

# pickup_prop now expects a Prop resource and RigidBody2D
func pickup_prop(prop_resource: Prop, prop_body: RigidBody2D) -> void:
	if !can_pickup():
		return

	held_prop = prop_resource
	current_prop_instance = prop_body # Directly store the RigidBody2D prop

	if (prop_body.has_method('picked_up')):
		prop_body.picked_up()

	# Disable physics on the prop body while held
	prop_body.set_deferred("freeze", true)
	# Remove from current parent
	var original_parent = prop_body.get_parent()
	original_parent.remove_child.call_deferred(prop_body)
	# Add prop_body to the marker directly
	marker.add_child.call_deferred(prop_body)
	# Reset transform
	prop_body.position = Vector2.ZERO
	prop_body.rotation = 0


	prop_picked_up.emit(current_prop_instance)
	equipped.emit(current_prop_instance) # Emit RigidBody2D prop

func throw_prop(direction: Vector2) -> void:
	if !held_prop or !current_prop_instance:
		return

	# Get the RigidBody2D prop directly (it's stored in current_prop_instance)
	var prop_body = current_prop_instance

	if prop_body:
		# Remove prop from marker
		marker.remove_child(prop_body)
		# Add the prop_body back to the original scene tree level (or perhaps the PropHolder's parent?)
		owner.get_parent().add_child(prop_body) # Or adjust parent as needed
		# Set global position to throw start position
		prop_body.global_position = marker.global_position

		# Enable physics and apply throw force
		prop_body.freeze = false
		prop_body.linear_velocity = direction.normalized() * throw_force
	else:
		printerr("current_prop_instance is not a valid RigidBody2D.")
		# Handle case where RigidBody2D is not found

	var thrown_prop = current_prop_instance
	var unequipped_prop_resource = held_prop # Keep track of Prop resource for unequipped signal

	current_prop_instance = null
	held_prop = null

	prop_thrown.emit(thrown_prop)
	unequipped.emit(thrown_prop) # Emit RigidBody2D prop

func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	if body.has_method("can_pickup"):
		if (can_pickup() and body.can_pickup(owner)):
			$PickupStream.playing = true

			var prop_resource = body.get("prop_resource")
			if prop_resource is Prop:
				pickup_prop(prop_resource, body) # Pass both Prop resource and body
			else:
				printerr("Body has 'prop_resource' but it is not of type Prop: ", body, prop_resource)
