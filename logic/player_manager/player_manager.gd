class_name PlayerManager
extends Node

@onready var player_hud_manager: PlayerHudManager = owner.get_node("PlayerHudManager")
signal start_of_game
signal end_of_game
var players: Array = []

func _ready() -> void:
	pass

func remove_player(player: Player) -> void:
	if players.has(player):
		players.erase(player)
	if players.is_empty():
		signal_end_of_game()

func add_player(player: Player) -> void:
	if not players.has(player):
		players.append(player)
		# Connect to the tree_exiting signal to remove player when freed
		player.tree_exiting.connect(func(): remove_player(player))

func spawn_player(controller_index: int) -> void:
	print("Spawning player for controller %d" % controller_index)
	var player_scene = preload("res://players/player.tscn")
	var player_instance = player_scene.instantiate()
	add_child(player_instance)
	player_instance.set_controller(controller_index)
	player_hud_manager.spawn_player_hud(player_instance)
	player_instance.player_wants_to_enter.connect(start)

func signal_end_of_game() -> void:
	end_of_game.emit()

func signal_start_of_game() -> void:
	start_of_game.emit()

func start(player: Player) -> void:
	player.start(owner.get_node("Level/StartPosition").position)
	add_player(player) # Add the new player to our array
	if not players.is_empty():
		signal_start_of_game()
