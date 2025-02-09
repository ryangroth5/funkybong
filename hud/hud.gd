extends CanvasLayer
signal start_game


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalGameState.game_state_change.connect(state_change)


func state_change(gs: GameStateManager.GameStateEnum) -> void:
	if (gs == GameStateManager.GameStateEnum.ATTRACT_MODE):
		show_message('Attract Mode')
	if (gs == GameStateManager.GameStateEnum.GAME_OVER):
		show_game_over()
	if (gs == GameStateManager.GameStateEnum.GAME_READY):
		clear_message()


func show_message(text):
	$Message.text = text;
	$Message.show();
	$MessageTimer.start();


func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Avoid the Ghosts"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()


func clear_message():
	$Message.hide();

func update_score(score):
	$ScoreLabel.text = str(score)


func _on_start_button_pressed() -> void:
	$StartButton.hide();
	start_game.emit();


func _on_message_timer_timeout() -> void:
	clear_message();
