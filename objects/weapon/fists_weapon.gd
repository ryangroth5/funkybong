extends RigidBody2D

# you can't drop your fists either
func _ready():
	freeze = true;

# you can't pick up your own fists.
func can_pickup():
	return false;


func get_texture()->Texture:
	return $Sprite2D.texture
