extends AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play("RESET")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_game_over_player_died() -> void:
	print("TEST")
	play("on_appear")
