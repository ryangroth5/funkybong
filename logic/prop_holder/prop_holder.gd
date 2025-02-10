class_name PropHolder
extends Node2D

signal prop_picked_up(prop: Prop) # Signal now emits Prop resource
signal prop_thrown(prop: Prop) # Signal now emits Prop resource
signal equipped(prop: Prop) # Signal now emits Prop resource
signal unequipped(prop: Prop) # Signal now emits Prop resource

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
var current_prop_instance: Node2D = null # Now a generic Node2D for the instantiated scene

# set the radius of effect to desired pickup radius
func _ready() -> void:
	$Area2D/CollisionShape2D.shape.radius = pickup_radius
	held_prop = null;

func show_prop():
	if !held_prop or !current_prop_instance: # Check if instance exists
		return
	current_prop_instance.visible = true

func hide_prop():
	if !held_prop or !current_prop_instance: # Check if instance exists
		return
	current_prop_instance.visible = false

func has_prop() -> bool:
	return held_prop != null

func which_prop() -> Prop: # Return Prop resource
	return held_prop

func can_pickup() -> bool:
	return enabled and held_prop == null

# pickup_prop now expects a Prop resource
func pickup_prop(prop_resource: Prop, prop_body: RigidBody2D) -> void:
	if !can_pickup():
		return

	held_prop = prop_resource

	# Instantiate the scene from the Prop resource
	if held_prop.scene:
		var prop_scene_instance = held_prop.scene.instantiate()
		marker.add_child.call_deferred(prop_scene_instance)
		current_prop_instance = prop_scene_instance
		current_prop_instance.position = Vector2.ZERO
		current_prop_instance.rotation = 0
	else:
		printerr("Prop resource has no scene assigned: ", held_prop)
		return # Exit if no scene is assigned

	if (prop_body.has_method('picked_up')):
		prop_body.picked_up()

	# Disable physics on the prop body while held
	prop_body.set_deferred("freeze", true)
	# Remove from current parent
	var original_parent = prop_body.get_parent()
	original_parent.remove_child.call_deferred(prop_body)
	# We don't add prop_body to the marker anymore, only the instantiated scene

	prop_picked_up.emit(held_prop)
	equipped.emit(held_prop)

func throw_prop(direction: Vector2) -> void:
	if !held_prop or !current_prop_instance:
		return

	# Get the RigidBody2D from the instantiated scene (assuming it's the root or a child)
	var prop_body = current_prop_instance as RigidBody2D # Or find child if needed

	if prop_body:
		# Remove scene from marker
		marker.remove_child(current_prop_instance)
		# Add the prop_body back to the original scene tree level (or perhaps the PropHolder's parent?)
		owner.get_parent().add_child(prop_body) # Or adjust parent as needed
		# Set global position to throw start position
		prop_body.global_position = marker.global_position

		# Enable physics and apply throw force
		prop_body.freeze = false
		prop_body.linear_velocity = direction.normalized() * throw_force
	else:
		printerr("Instantiated prop scene does not have a RigidBody2D as root or child.")
		# Handle case where RigidBody2D is not found in instantiated scene

	var thrown_prop = held_prop

	current_prop_instance = null
	held_prop = null

	prop_thrown.emit(thrown_prop)
	unequipped.emit(thrown_prop)

func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	if body.has_method("can_pickup"):
		if (can_pickup() and body.can_pickup(owner)):
			$PickupStream.playing = true
			
			# Assuming the body has a "prop_resource" property of type Prop
			var prop_resource = body.get("prop_resource")
			if prop_resource is Prop:
				pickup_prop(prop_resource, body) # Pass both Prop resource and body
			else:
				printerr("Body has 'prop_resource' but it is not of type Prop: ", body, prop_resource)
