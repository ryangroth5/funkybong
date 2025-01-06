extends Area2D
@export var mob_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("MobSpawnersGroup")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func spawn() -> void:
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Set the mob's position to a random location.
	mob.position = position


	# Choose the velocity for the mob.
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	if mob is CharacterBody2D:
		mob.velocity = velocity;
	elif mob is RigidBody2D:
		mob.linear_velocity = velocity;
		

	# Spawn the mob by adding it to the Main scene.
	get_parent().add_child(mob)
