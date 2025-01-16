class_name HitBox
extends Area2D

@export var damage := 10


func _init() -> void:
	collision_layer = GlobalConstants.WEAPON_LAYER
	collision_mask = 0;
