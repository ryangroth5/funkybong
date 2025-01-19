class_name PlayerHudManager
extends Node

var player_huds: Array = []


func spawn_player_hud(player: Player):
	var player_hud: PlayerHud = preload("./PlayerHud.tscn").instantiate()
	player_hud.initialize(player, owner.get_node("PlayerManager"));
	player_hud.player_hud_removed.connect(_on_player_hud_removed)
	add_child(player_hud)
	player_huds.append(player_hud)
	update_hud_positions()

func _on_player_hud_removed(player_id: int) -> void:
	# Remove the HUD for the given player_id
	player_huds = player_huds.filter(func(hud): return hud.player.controller_number != player_id)
	
	# Update positions of remaining HUDs
	update_hud_positions()


func update_hud_positions():
	for i in player_huds.size():
		player_huds[i].update_position()
