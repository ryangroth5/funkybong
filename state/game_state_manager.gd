class_name GameStateManager
extends Node

enum GameStateEnum {
	# before players enter
	ATTRACT_MODE,
	# players are putting coins in (e.g. select button)
	PLAYER_READY,
	# players singal they are entering (e.g. start button)
	GAME_READY,
	# all players dead or time up.
	GAME_OVER,
}
@export var game_state: GameStateEnum = GameStateEnum.ATTRACT_MODE;


signal game_state_change(gsc: GameStateEnum);
signal hud_update(Dictionary)

var message_bus: MessageBus = null;
var enemies_escaped = 0;
var enemies_killed = 0;

var player_manager: PlayerManager;
var controller_manager: ControllerManager;


func initialize(pm: PlayerManager, cm: ControllerManager, phm: PlayerHudManager):
	controller_manager = cm;
	player_manager = pm;
	player_manager.initialize(phm);
	controller_manager.controller_connected.connect(_on_controller_connected)
	player_manager.players_can_enter.connect(start_game)

func start_game():
	transition_state(GameStateEnum.GAME_READY);

	
func _ready() -> void:
	GlobalMessageBus.enemy_died.connect(enemy_died)
	GlobalMessageBus.enemy_escaped.connect(enemy_escaped)

func get_hudstate() -> Dictionary:
	return {
	"enemies_escaped": enemies_escaped,
	"enemies_killed": enemies_killed
}

func transition_state(new_game_state) -> void:
	if(new_game_state != game_state):
		game_state = new_game_state;
		game_state_change.emit(game_state)


func enemy_died() -> void:
	enemies_killed += 1;
	hud_update.emit(get_hudstate())

func enemy_escaped() -> void:
	enemies_escaped += 1;
	hud_update.emit(get_hudstate())
	

func reset_state():
	enemies_killed = 0;
	enemies_escaped = 0;
	hud_update.emit(get_hudstate())

func _on_controller_connected(controller_index: int) -> void:
	spawn_player(controller_index)


func spawn_player(controller_index: int) -> void:
	transition_state(GameStateEnum.PLAYER_READY);
	player_manager.spawn_player(controller_index);
