extends Node

var score: int = 0

@onready var controller_manager: Node = $ControllerManager


func _ready() -> void:
	GlobalGameState.initialize($PlayerManager, $ControllerManager, $PlayerHudManager);
	GlobalGameState.game_state_change.connect(game_state_change)


func game_state_change(gs: GameStateManager.GameStateEnum):
	if(gs == GameStateManager.GameStateEnum.GAME_READY):
		new_game()
	
	if(gs==GameStateManager.GameStateEnum.GAME_OVER):
		game_over()

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

func _on_player_manager_start_of_game() -> void:
	new_game()

func _on_player_manager_end_of_game() -> void:
	game_over()
