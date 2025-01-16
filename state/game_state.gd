class_name GameStateClass
extends Node
# I'm not using this yet.
# Example game state variables
var player_count = 1
var score = 0
var health = 100
var level_name = "Level1"


func reset_state():
	player_count = 1
	score = 0
	health = 100
	level_name = "Level1"
