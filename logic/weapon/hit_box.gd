class_name HitBox
extends Area2D

@export var damage := 10
var enabled = true;


func disable():
	enabled = false;
	monitoring = false;
	monitorable = false;
	
func enable():
	enabled = true;
	monitoring = true;
	monitorable = true;
	
func _init() -> void:
	collision_layer = GlobalConstants.WEAPON_LAYER
	collision_mask = 0;
