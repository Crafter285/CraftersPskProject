shader_type spatial;

render_mode unshaded, cull_disabled;

uniform sampler2D lightningNoise1;
uniform sampler2D lightningNoise2;
uniform vec3 tint : source_color;
uniform float effect_speed = 0.2;

// vertex uniforms
uniform float distortionVertex : hint_range(0.0, 0.3, 0.005) = 0.03;
uniform float speedVertex : hint_range(0.0, 1.0, 0.005) = 0.5;
uniform sampler2D noiseVertex;
uniform float lightning_height : hint_range(0.0, 5.0, 0.01) = 0.1;

uniform vec4 emission_color : source_color;
uniform float emission_strength = 1.0;

void vertex()
{
	VERTEX += NORMAL * lightning_height;
	
	float noiseVal = (texture(noiseVertex, UV + (TIME * speedVertex)).r * 2.0) - 1.0;
	vec3 displacement = NORMAL * noiseVal * distortionVertex;
	VERTEX += displacement;
}

void fragment()
{
	float layer1 = texture(lightningNoise1, UV + (TIME * effect_speed)).r * sin(TIME * 5.0);
	float layer2 = texture(lightningNoise2, UV - (TIME * effect_speed)).r * cos(TIME * 5.0);
	ALBEDO = vec3(layer1 + layer2) * tint;
	EMISSION = emission_color.rgb * emission_strength;
	ALPHA = layer1 + layer2;
}