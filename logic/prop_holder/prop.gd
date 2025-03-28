class_name Prop extends Resource

@export var prop_name: String = "Generic Prop"
@export var description: String = "A basic prop."
@export var icon: Texture2D # Optional: for UI representation
var is_held: bool = false;


# Virtual function - can be overridden by specific prop types
func picked_up(holder):
	is_held = true;
	print("Prop picked up: " + prop_name)

# Virtual function - can be overridden by specific prop types
func dropped(holder):
	is_held = false;
	print("Prop dropped: " + prop_name)

# Virtual function - can be overridden by specific prop types
func use(holder):
	print("Prop used: " + prop_name)
