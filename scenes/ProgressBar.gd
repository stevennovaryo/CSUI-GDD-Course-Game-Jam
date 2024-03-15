extends TextureProgressBar

@onready var player_movement: PlayerMovement = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	value = player_movement.current_hitpoint * 100.0 / player_movement.max_hit_point
