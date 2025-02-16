class_name Prop extends Resource

@export var prop_name: String = "Generic Prop"
@export var description: String = "A basic prop."
@export var icon: Texture2D # Optional: for UI representation

# Virtual function - can be overridden by specific prop types
func picked_up(holder):
	print("Prop picked up: " + prop_name)

# Virtual function - can be overridden by specific prop types
func dropped(holder):
	print("Prop dropped: " + prop_name)

# Virtual function - can be overridden by specific prop types
func use(holder):
	print("Prop used: " + prop_name)
