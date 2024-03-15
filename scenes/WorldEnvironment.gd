extends WorldEnvironment
class_name MainWorldEnvironment

static var main_env: MainWorldEnvironment = self

func change_color_correction_to_red():
	var gradient_data := {
		0.0: Color(0, 0, 0, 1),
		1.0: Color("#ff6161", 1)
	}
		
	var gradient = Gradient.new()
	gradient.offsets = gradient_data.keys()
	gradient.colors = gradient_data.values()

	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	
	environment.adjustment_color_correction = gradient_texture
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_player_low_health() -> void:
	change_color_correction_to_red()


func _on_player_player_died() -> void:
	pass # Replace with function body.
