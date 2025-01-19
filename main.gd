extends Node

var score: int = 0

@onready var controller_manager: Node = $ControllerManager


func _ready() -> void:
	controller_manager.controller_connected.connect(_on_controller_connected)

func game_over() -> void:
	get_tree().call_group("PlayersGroup", "queue_free")
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game() -> void:
	score = 0
	$GlobalSpawnTimer.start();
	#controller_manager.reset_controllers()

func _on_start_timer_timeout() -> void:
	$GlobalSpawnTimer.start()
	$ScoreTimer.start()

func _on_score_timer_timeout() -> void:
	score += 1
	$HUD.update_score(score)

func _on_hud_start_game() -> void:
	new_game()

func _on_global_spawn_timer_timeout() -> void:
	var spawners = get_tree().get_nodes_in_group("MobSpawnersGroup")
	if (spawners.is_empty()):
		printerr("Expected a spawner somewhere in the mob spawners group. Make sure the map has a spawner and that the spawner is in the MobSpawnersGroup")
	for spawner in spawners:
		spawner.spawn()

func _on_controller_connected(controller_index: int) -> void:
	spawn_player(controller_index)


func spawn_player(controller_index: int) -> void:
	$PlayerManager.spawn_player(controller_index);


func _on_player_manager_start_of_game() -> void:
	new_game()




func _on_player_manager_end_of_game() -> void:
	game_over()
