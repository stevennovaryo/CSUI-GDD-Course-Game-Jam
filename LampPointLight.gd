extends PointLight2D

@export var initial_energy = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	energy = initial_energy
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_road_side_lamp_on_hit(energy: float, texture_scale: float) -> void:
	self.energy = energy * initial_energy
	self.texture_scale = texture_scale
