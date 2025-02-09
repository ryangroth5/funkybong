class_name MessageBus
extends Node


# Enemy related signals
signal enemy_died(enemy: Node)
signal enemy_escaped(enemy: Node)

# Methods to emit signals
func notify_enemy_died(enemy: Node) -> void:
	enemy_died.emit(enemy)
	
func notify_enemy_escaped(enemy: Node) -> void:
	enemy_escaped.emit(enemy)
