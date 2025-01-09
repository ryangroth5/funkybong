extends Node

signal controller_connected(controller_index: int)

# Maximum number of players
@export var MAX_PLAYERS: int = 4

# Track assigned controllers
var assigned_controllers: Dictionary = {}


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()

	for i in range(MAX_PLAYERS):
		var action_name = "c%d_start" % i
		if Input.is_action_just_pressed(action_name):
			handle_start_pressed(i)


func handle_start_pressed(controller_index: int) -> void:
	var controller_id = "c%d" % controller_index

	# Check if the controller is already assigned to a player
	if controller_id in assigned_controllers:
		print("Controller %s already assigned to a player." % controller_id)
		return

	# Assign controller to a new player if there is room
	if assigned_controllers.size() < MAX_PLAYERS:
		assigned_controllers[controller_id] = true
		controller_connected.emit(controller_index)
	else:
		print("Max players reached. Cannot assign controller %s." % controller_id)


func handle_select_pressed(controller_index: int) -> void:
	var controller_id = "c%d" % controller_index
	print("Select button pressed on controller %s." % controller_id)


func unassign_controller(controller_index: int) -> void:
	var controller_id = "c%d" % controller_index
	if controller_id in assigned_controllers:
		assigned_controllers.erase(controller_id)


func reset_controllers() -> void:
	assigned_controllers.clear()
