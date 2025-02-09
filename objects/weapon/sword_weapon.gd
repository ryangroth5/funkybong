class_name SwordWeapon
extends WeaponBody2D


var check_interval: float = 0.25 # Quarter second intervals

func can_pickup(_who: Node2D):
	var powner = owner;
	return not powner is CharacterBody2D

func get_texture() -> Texture:
	return $Sprite.texture
	
func picked_up():
	# Disable physics when picked up - Godot 4 version
	set_deferred("freeze", true)
	# a picked up sword will not displace the person picking it up.
	$CollisionShape2D.disabled = true;
	
	#hitbox becomes helpful after the weapon is pickedup otherwise it 
	#just does damage.
	$HitBox.enable()

func dropped() -> void:
	# Re-enable physics when dropped - Godot 4 version
	freeze = false
	#enables kicking the sword
	$CollisionShape2D.disabled = false;

	# we'll re-enable hitbox as soon as the weapon is on the ground 
	# so it doesn't damage the thrower.
	# Create a repeating timer to check velocity
	var timer = get_tree().create_timer(check_interval)
	timer.timeout.connect(_check_movement.bind(timer))
	$HitBox.enable() # Enable hitbox initially

func is_melee_weapon():
	return true


func _check_movement(timer: SceneTreeTimer) -> void:
	if linear_velocity.length() < velocity_threshold:
		# Object has slowed down enough, disable hitbox and stop checking
		$HitBox.disable()
		timer.timeout.disconnect(_check_movement)
	else:
		# Still moving fast enough, create new timer and keep checking
		var new_timer = get_tree().create_timer(check_interval)
		new_timer.timeout.connect(_check_movement.bind(new_timer))
