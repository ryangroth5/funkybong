class_name PropHolder
extends Node2D

signal prop_picked_up(prop: RigidBody2D)
signal prop_thrown(prop: RigidBody2D)
signal equipped(weapon: PackedScene)
signal unequipped(weapon: PackedScene)

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


# Change the type to PackedScene but we'll ensure it contains a RigidBody2D
@export var held_prop: PackedScene = null
@onready var marker: Marker2D = $Marker2D
var current_prop_instance: RigidBody2D = null # To keep track of the instantiated prop

# set the radius of effect to desired pickup radius
func _ready() -> void:
	$Area2D/CollisionShape2D.shape.radius = pickup_radius
	held_prop = null;

func show_prop():
	if !held_prop:
		return
	held_prop.visible = true

func hide_prop():
	if (!held_prop):
		return
	held_prop.visible = false

func has_prop() -> bool:
	return held_prop != null
	
func which_prop() -> PackedScene:
	return held_prop
	
func can_pickup() -> bool:
	return enabled and held_prop == null

func pickup_prop(prop: RigidBody2D) -> void:
	if !can_pickup():
		return

	# Create PackedScene from the prop
	var packed_scene = PackedScene.new()
	packed_scene.pack(prop)
	print("prop has is_melee_weapon method: %s" % [prop.has_method("is_melee_weapon")])
	print("packed_scene has is_melee_weapon method: %s" % [packed_scene.has_method("is_melee_weapon")])
	held_prop = packed_scene
	
	if (prop.has_method('picked_up')):
		prop.picked_up()
	
	# Store the original prop instance
	current_prop_instance = prop
	# Disable physics on the prop while held
	current_prop_instance.set_deferred("freeze", true)
	# Remove from current parent
	var original_parent = current_prop_instance.get_parent()
	original_parent.remove_child.call_deferred(current_prop_instance)
	# Add to marker
	marker.add_child.call_deferred(current_prop_instance)
	# Reset transform
	current_prop_instance.position = Vector2.ZERO
	current_prop_instance.rotation = 0
	
	prop_picked_up.emit(current_prop_instance)
	equipped.emit(held_prop)

func throw_prop(direction: Vector2) -> void:
	if !held_prop or !current_prop_instance:
		return
		
	# Remove from marker
	marker.remove_child(current_prop_instance)
	# Add back to original scene tree level
	owner.get_parent().add_child(current_prop_instance)
	# Set global position to throw start position
	current_prop_instance.global_position = marker.global_position
	
	# Enable physics and apply throw force
	current_prop_instance.freeze = false
	current_prop_instance.linear_velocity = direction.normalized() * throw_force
	
	var thrown_prop = current_prop_instance
	var thrown_scene = held_prop
	
	current_prop_instance = null
	held_prop = null
	
	prop_thrown.emit(thrown_prop)
	unequipped.emit(thrown_scene)

func _on_area_2d_body_entered(body: RigidBody2D) -> void:
	if body.has_method("can_pickup"):
		if (can_pickup() and body.can_pickup(owner)):
			$PickupStream.playing = true
			pickup_prop(body as RigidBody2D)
