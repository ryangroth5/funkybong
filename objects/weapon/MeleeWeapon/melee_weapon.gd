class_name MeleeWeapon
extends Node2D
@onready var current_weapon: RigidBody2D = $CurrentWeapon;
@export var default_weapon_scene: PackedScene

signal equipped(weapon: PackedScene);
signal unequipped(weapon: PackedScene);

# i am using default weapons scene mostly to animate
# a character, but when I am in the actual game, this should be
# set programatically
func _init() -> void:
	current_weapon = null;
	default_weapon_scene = null;

func is_equipped() -> bool:
	return current_weapon == null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	remove_weapon()
	if (default_weapon_scene):
		load_weapon(default_weapon_scene)

func load_weapon(weapon_scene: PackedScene):
	# Remove the current weapon if it exists
	if current_weapon:
		current_weapon.queue_free()
		current_weapon = null

	# Instance the new weapon scene and add it as a child
	current_weapon = weapon_scene.instantiate()
	current_weapon.freeze = true;
	add_child(current_weapon)
	current_weapon.position = Vector2.ZERO # Adjust for 2D; use appropriate properties for 3D
	equipped.emit(current_weapon);

func remove_weapon() -> void:
	if current_weapon:
		current_weapon.freeze = true;
		unequipped.emit(default_weapon_scene)
		current_weapon.queue_free()
		current_weapon = null
