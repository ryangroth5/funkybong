extends Node
var score

# Track assigned controllers
var assigned_controllers: Dictionary = {}

# Maximum number of players
const MAX_PLAYERS: int = 4


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass ;

func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	get_tree().call_group("PlayersGroup", "queue_free");
	assigned_controllers={}
	

func _on_start_timer_timeout() -> void:
	$GlobalSpawnTimer.start();
	$ScoreTimer.start();


func _on_score_timer_timeout() -> void:
	score += 1;
	$HUD.update_score(score)


func _on_hud_start_game() -> void:
	new_game();

func _on_global_spawn_timer_timeout() -> void:
	var spawners = get_tree().get_nodes_in_group("MobSpawnersGroup")
	for spawner in spawners:
		spawner.spawn()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
	for i in range(MAX_PLAYERS): # Assuming controllers "c0" to "c4"
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
		spawn_player(controller_index)
	else:
		print("Max players reached. Cannot assign controller %s." % controller_id)

func handle_select_pressed(controller_index: int) -> void:
	var controller_id = "c%d" % controller_index
	# Example: Print a message or handle other logic for the "select" button
	print("Select button pressed on controller %s." % controller_id)

func spawn_player(controller_index: int) -> void:
	print("Spawning player for controller %d" % controller_index)
	var player_scene = preload("res://player.tscn")
	var player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.set_controller(controller_index)
	player_instance.start($StartPosition.position)
