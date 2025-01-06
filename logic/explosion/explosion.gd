extends Node2D
@export var animation_root = "skeleton"
@export var explosion_force: float = 600.0
@export var explosion_spread: float = 360.0
@export var blood_particles_duration: float = 0.5
@export var part_lifetime: float = 5.0
@export var min_force_variation: float = 0.8
@export var max_force_variation: float = 1.2

@onready var particles: CPUParticles2D = $BloodParticles;

var body_part_scene = preload("res://logic/explosion/body_part.tscn")
var parts_to_spawn = {
	"arm": 2,
	"leg": 2,
	"body": 1,
	"head": 1
}

func _ready() -> void:
	# You might want to call this when the character dies instead
	create_explosion()

func create_explosion() -> void:
	
	# Load a particle material (you'll need to create this in the editor)
	
	particles.amount = 100
	particles.lifetime = blood_particles_duration
	particles.one_shot = true
	particles.emitting = true
	
	# Create a timer to spawn body parts after the blood effect
	var timer = get_tree().create_timer(0.1) # Small delay before parts appear
	timer.timeout.connect(spawn_body_parts)
	
	# Clean up particles after they're done
	var cleanup_timer = get_tree().create_timer(blood_particles_duration + 0.1)
	cleanup_timer.timeout.connect(func(): particles.queue_free())


func spawn_body_parts() -> void:
	for part_name in parts_to_spawn:
		var count = parts_to_spawn[part_name]
		for i in range(count):
			var body_part = body_part_scene.instantiate()
						# Set the position to the explosion center
			body_part.position = Vector2.ZERO
			
			# Set the animation property
			body_part.animation = animation_root + "_" + part_name
			
			# Randomize force for each part
			var force_multiplier = randf_range(min_force_variation, max_force_variation)
			body_part.initial_force = explosion_force * force_multiplier
			
			# Set other properties
			body_part.effect_duration = part_lifetime
			body_part.bounce_count = 2
			body_part.initial_orientation = -1 # Random rotation
			add_child(body_part)
			
