extends AnimatedSprite2D

var last_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	last_position = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	rotation = rotation / 2
	last_position = global_position
