shader_type spatial;

uniform sampler2D image;
uniform vec4 color: source_color = vec4(0.894, 0.0, 0.914, 1.0);
uniform float energy: hint_range(0, 16) = 4.5;
uniform float threshold = 0.1;

void fragment() {
	EMISSION = color.rgb * energy;
	ALPHA = 0.0;
}

void light() {
	vec4 pixel = textureLod(image, UV, 1.0);

	float brightness = (pixel.r + pixel.g + pixel.b) / 3.0;
	float alpha_mask = smoothstep(threshold, threshold + 0.1, brightness);

	DIFFUSE_LIGHT = vec3(0.0);
	SPECULAR_LIGHT = vec3(0.0);

	ALPHA = ATTENUATION * pixel.a * alpha_mask;

	if (ATTENUATION == 1.0) {
		ALPHA = 0.0;
	}
}