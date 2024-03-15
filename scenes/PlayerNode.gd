extends Node2D
class_name PlayerNode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


signal player_low_health
signal player_died

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_player_low_health() -> void:
	player_low_health.emit()


func _on_player_player_died() -> void:
	player_died.emit()
