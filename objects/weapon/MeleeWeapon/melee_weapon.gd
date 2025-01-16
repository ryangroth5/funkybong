class_name MeleeWeapon
extends Node2D
@onready var current_weapon:Node2D = $CurrentWeapon;
@export var default_weapon_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(default_weapon_scene):
		load_weapon(default_weapon_scene)

func load_weapon(weapon_scene: PackedScene):
	# Remove the current weapon if it exists
	if current_weapon:
		current_weapon.queue_free()
		current_weapon = null

	# Instance the new weapon scene and add it as a child
	current_weapon = weapon_scene.instantiate()
	add_child(current_weapon)
	current_weapon.position = Vector2.ZERO  # Adjust for 2D; use appropriate properties for 3D

func remove_weapon():
	if current_weapon:
		current_weapon.queue_free()
		current_weapon = null
