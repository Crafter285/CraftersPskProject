shader_type spatial;

uniform sampler2D noise : source_color;
uniform float move_speed = 0.1;
uniform vec2 move_direction = vec2(0.0, 1.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3(1.0, 1.0, 1.0);
	EMISSION = vec3(0.0, 0.0, 0.0);
	
	vec2 new_uv = UV + vec2((TIME * move_speed)*move_direction.x, (TIME * move_speed)*move_direction.y);
	vec4 noise_color = texture(noise, new_uv);
	
	ALBEDO = noise_color.rgb;
	EMISSION = noise_color.rgb/2.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
