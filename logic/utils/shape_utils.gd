# shape_utils.gd
class_name ShapeUtils
extends Object

static func get_shape_largest_dimension(shape: Shape2D) -> float:
	var largest_dimension: float = 0.0
	
	if shape is RectangleShape2D:
		largest_dimension = max(shape.size.x, shape.size.y)
	elif shape is CircleShape2D:
		largest_dimension = shape.radius * 2
	elif shape is CapsuleShape2D:
		largest_dimension = max(shape.radius * 2, shape.height)
	
	return largest_dimension

static func get_collision_shape_largest_dimension(collision_shape: CollisionShape2D) -> float:
	if collision_shape and collision_shape.shape:
		return get_shape_largest_dimension(collision_shape.shape)
	return 0.0
