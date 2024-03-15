shader_type canvas_item;

uniform float red_tint: hint_range(0.0, 1) = 0.2;
uniform float white_multiplier: hint_range(0.0, 100, 0.1) = 1;
uniform float enabled: hint_range(0.0, 1.0, 1) = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if (enabled == 1.0) {
		COLOR.r = red_tint;		
	}
	COLOR.r = COLOR.r * white_multiplier;
	COLOR.b = COLOR.b * white_multiplier;
	COLOR.g = COLOR.g * white_multiplier;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
