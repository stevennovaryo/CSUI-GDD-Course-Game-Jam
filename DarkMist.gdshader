shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//LIGHT_VERTEX. = 0.0;
}

 void light() {
	DIFFUSE_LIGHT.b = 0.0;
}
