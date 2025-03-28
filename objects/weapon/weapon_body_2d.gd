class_name WeaponBody2D # Allows other scripts to recognize this as a generic prop
extends RigidBody2D


var is_in_flight: bool = false
var velocity_threshold: float = 10.0 # Adjust based on game needs
var ground_timer: float = 0.0
var ground_time_threshold: float = 0.2 # Time needed to confirm it's resting
var can_cause_damage: bool = false # Only deals damage when in flight


func _physics_process(delta):
	update_flight_status(delta)

func update_flight_status(delta):
	if linear_velocity.length() > velocity_threshold:
		is_in_flight = true
		can_cause_damage = true
		ground_timer = 0.0 # Reset ground timer since it's moving
	else:
		ground_timer += delta
		if ground_timer >= ground_time_threshold:
			is_in_flight = false
			can_cause_damage = false # Stationary objects don't cause damage

func _on_thrown():
	is_in_flight = true
	can_cause_damage = true
