class_name PlayerHud
extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var player_health_label = $ColorRect/PlayerHealthLabel
@onready var current_item_sprite = $ColorRect/CurrentItemSprite
@onready var current_player_sprite = $ColorRect/CurrentPlayerSprite
@onready var current_player_label = $ColorRect/CurrentPlayerLabel


enum HudStates {
	HASNT_ENTERED,
	PLAYING,
	CONTINUING
}


signal player_hud_removed(player_number: int);

var health: int = 100
var player: Player = null;
var player_number: int = 0;
var hud_state: HudStates = HudStates.HASNT_ENTERED;
var player_manager: PlayerManager = null;

func initialize(new_player: Player, new_player_manager: PlayerManager) -> void:
	player = new_player;
	player_number = player.controller_number;
	player.player_died.connect(on_player_died)
	player.health_changed.connect(on_health_changed)
	player.player_wants_to_enter.connect(on_player_enter)
	player_manager = new_player_manager;

func transition_state(new_state: HudStates) -> void:
	match new_state:
		HudStates.PLAYING:
			if (health > 0):
				player.can_enter = true;
				player_manager.start(player)
		HudStates.CONTINUING:
			pass ;
		HudStates.HASNT_ENTERED:
			pass ;
		_: # Default case
			push_error("Invalid HUD state: " + str(hud_state))
	hud_state = new_state;
	
		
func ready() -> void:
	update_player_health()
	update_player_num()
		

func update_position():
	var screen_size = get_viewport().get_visible_rect().size
	var hud_width = screen_size.x / 4
	color_rect.position = Vector2(player_number * hud_width, screen_size.y - color_rect.size.y) # Bottom of the screen
	color_rect.custom_minimum_size = Vector2(hud_width, color_rect.size.y) # Width spans 1/4 of the screen

func on_health_changed(new_health: int):
	health = new_health
	if(health>0):
		player.can_enter = true;
	update_player_health();

func update_player_health() -> void:
	player_health_label.text = "Health: %d " % health

func update_player_num() -> void:
	current_player_label.text = "Player %d" % player_number

func on_player_died():
	transition_state(HudStates.CONTINUING)
	queue_free()
	player_hud_removed.emit(player_number)


func on_player_enter():
	transition_state(HudStates.PLAYING)
