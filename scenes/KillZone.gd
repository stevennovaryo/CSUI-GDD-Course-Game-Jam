extends Node2D

@onready var player_node: PlayerNode = $"../CanvasModulate/Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_node:
		global_position.x = player_node.get_child(0).global_position.x
