shader_type canvas_item;
render_mode light_only;
void fragment() {
	
}

void light() {
	float cNdotL = max(0.0, dot(vec3(1, 1, 1), LIGHT_DIRECTION));
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
	// LIGHT.r = min(COLOR.r - LIGHT.r, LIGHT.r);
	//LIGHT.g = min(COLOR.g - LIGHT.g, LIGHT.g);
	// LIGHT.b = min(COLOR.b - LIGHT.b, LIGHT.b);
	// LIGHT.rgb = min(COLOR.rgb - LIGHT.rgb, LIGHT.rgb);
}