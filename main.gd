extends Node



var score


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()

func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	


func _on_start_timer_timeout() -> void:

	$ScoreTimer.start();





func _on_score_timer_timeout() -> void:
	score +=1;
	$HUD.update_score(score)


func _on_hud_start_game() -> void:
	new_game();
