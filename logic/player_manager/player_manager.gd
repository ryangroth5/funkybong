class_name PlayerManager
extends Node

# this class is repsonsible for managing the number of players on the 
# screen in the game. 


var players: Array = []

signal all_players_dead;
# at least one player has put in coins and has hit start.
signal players_can_enter;

var player_hud_manager: PlayerHudManager

func initialize(phm: PlayerHudManager) -> void:
	player_hud_manager = phm;

func _ready() -> void:
	GlobalGameState.game_state_change.connect(game_state_changed)
	
# put the player on the board
func start(player: Player) -> void:
	player.start(owner.get_node("Level/StartPosition").position)
	add_player(player) # Add the new player to our array
	if not players.is_empty():
		players_can_enter.emit()	
	

# put the players in that are ready to go in.
func game_state_changed(gs: GameStateManager.GameStateEnum) -> void:
	if (gs == GameStateManager.GameStateEnum.GAME_READY):
		for player in players:
			start(player)

		
func remove_player(player: Player) -> void:
	if players.has(player):
		players.erase(player)
	if players.is_empty():
		all_players_dead.emit();

func add_player(player: Player) -> void:
	if not players.has(player):
		players.append(player)
		# Connect to the tree_exiting signal to remove player when freed
		player.tree_exiting.connect(func(): remove_player(player))


# used to put the player into the game, the player then controlls the controller
# called by game state manager currently to connect the controller manager to the 
# player
func spawn_player(controller_index: int) -> void:
	print("Spawning player for controller %d" % controller_index)
	var player_scene = preload("res://players/player.tscn")
	var player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.set_controller(controller_index)

	player_hud_manager.spawn_player_hud(player_instance)
	player_instance.player_wants_to_enter.connect(start)
