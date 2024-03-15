shader_type canvas_item;

uniform float red_weight: hint_range(0.0, 1) = 0.2;
uniform float blue_weight: hint_range(0.0, 1) = 0.2;
uniform float green_weight: hint_range(0.0, 1) = 0.2;
uniform float brightness: hint_range(0.0, 5) = 1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    COLOR = texture(TEXTURE, UV);
    float avg = (COLOR.r * red_weight + COLOR.g * green_weight + COLOR.b * blue_weight) / (red_weight + blue_weight + green_weight);
	COLOR.rgb = vec3(avg) * brightness;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
