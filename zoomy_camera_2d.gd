extends Camera2D

@export var padding: float = 100.0 # Extra space around players
@export var min_zoom: float = 0.5 # Minimum zoom (most zoomed-out)
@export var max_zoom: float = 2.0 # Maximum zoom (most zoomed-in)
@export var zoom_speed: float = 5.0 # Speed of zoom transitions

# Group name for players
@export var player_group: String = "PlayersGroup"

func _process(delta: float) -> void:
	update_camera(delta)

func update_camera(delta: float) -> void:
	# Get all player positions
	var player_positions: Array[Vector2] = []
	for player in get_tree().get_nodes_in_group(player_group):
		if player.is_inside_tree():
			player_positions.append(player.global_position)

	if player_positions.is_empty():
		return # No players to track

	# Calculate bounding box around players
	var min_pos = player_positions[0]
	var max_pos = player_positions[0]
	for pos in player_positions:
		min_pos = min_pos.min(pos)
		max_pos = max_pos.max(pos)

	# Add padding to bounding box
	min_pos -= Vector2(padding, padding)
	max_pos += Vector2(padding, padding)

	# Calculate target position and size
	var target_position = (min_pos + max_pos) / 2
	var target_size = max_pos - min_pos

	# Calculate zoom while maintaining aspect ratio
	var screen_size = get_viewport().size
	var x_zoom = target_size.x / screen_size.x
	var y_zoom = target_size.y / screen_size.y
	
	# Use the larger zoom to ensure everything fits in view
	var final_zoom = max(x_zoom, y_zoom)
	
	# Clamp zoom to defined range
	final_zoom = clamp(final_zoom, min_zoom, max_zoom)
	
	var target_zoom = Vector2(1.0 / final_zoom, 1.0 / final_zoom)

	# Smoothly move camera and adjust zoom
	global_position = global_position.lerp(target_position, delta * zoom_speed)
	zoom = zoom.lerp(target_zoom, delta * zoom_speed)
