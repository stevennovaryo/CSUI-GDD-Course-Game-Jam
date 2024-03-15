extends Sprite2D

@onready var the_lamp: TheLamp = $"../TheLamp"
@onready var fill_ratio: float = 0.4
@onready var minimum_fill: float = 0.1

var gradient_data := {
	0.0: Color(0, 0, 0, 0),
	.45: Color(0, 0, 0, 0),
	.55: Color(0, 0, 0, 0.35),
	0.75: Color(0, 0, 0, 1),
	1.0: Color(0, 0, 0, 1)
}
var gradient_size = 600
var gradient_texture: GradientTexture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	var gradient = Gradient.new()
	gradient.offsets = gradient_data.keys()
	gradient.colors = gradient_data.values()

	gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	gradient_texture.width = gradient_size
	gradient_texture.height = gradient_size
	gradient_texture.fill = GradientTexture2D.FILL_RADIAL
	gradient_texture.fill_from = Vector2(0.5, 0.5)
	gradient_texture.fill_to = fill_ratio * Vector2(0.5, 0.5) + gradient_texture.fill_from

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = the_lamp.position.x
	var cur_fill_ratio = max(0, the_lamp.get_light_energy_ratio() * the_lamp.get_light_energy_ratio() * the_lamp.get_light_energy_ratio() * (0.5 - minimum_fill)) + minimum_fill
	gradient_texture.fill_to = cur_fill_ratio * Vector2(1, 1) + gradient_texture.fill_from

	texture = gradient_texture
	pass
