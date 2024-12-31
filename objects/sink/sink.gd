extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("DespawnableMobsGroup"):
		# Disable physics processing
		body.set_physics_process(false)
		if body.has_node("CollisionShape2D"):
			body.get_node("CollisionShape2D").set_deferred("disabled", true)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(body, "rotation", body.rotation + (PI * 2 * 3), 0.5)
		tween.tween_property(body, "scale", Vector2.ZERO, 0.5)
		
		await tween.finished
		body.queue_free()
