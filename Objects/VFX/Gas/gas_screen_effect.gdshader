shader_type canvas_item;

uniform sampler2D existing_screen_texture: hint_screen_texture, filter_linear_mipmap;

uniform float frequency = 60.0;
uniform float amplitude = 0.003;

uniform float radial_frequency = 5.0;
uniform float radial_amount = 0.005;

uniform float rotation_frequency = 2.0; // Frequency for rotational distortion
uniform float rotation_amount = 0.03;    // Amount of rotation distortion

uniform float color_distortion_amount = 0.005;  // Amount of color distortion (RGB shift)
uniform float chromatic_aberration_amount = 0.01; // Chromatic aberration strength

void fragment() {
    vec2 new_uv = SCREEN_UV;

    // Apply wavy distortion (horizontal sine wave)
    new_uv.x += sin(new_uv.y * frequency + TIME) * amplitude;

    // Radial distortion (circular warping)
    vec2 center = vec2(0.5, 0.5);
    vec2 offset = new_uv - center;
    float dist = length(offset);
    float radial_offset = sin(dist * radial_frequency - TIME) * radial_amount;
    new_uv += normalize(offset) * radial_offset;

    // Rotational radial distortion (rotating pixels around the center)
    float angle = sin(dist * rotation_frequency + TIME) * rotation_amount; // Angle based on distance from center and time
    mat2 rotation_matrix = mat2(
        vec2(cos(angle), sin(angle)),  // First column of the matrix
        vec2(-sin(angle), cos(angle))  // Second column of the matrix
    );
    new_uv = center + rotation_matrix * (new_uv - center); // Apply the rotation matrix

    // Color distortion: Shift RGB channels slightly based on `color_distortion_amount`
    vec3 color_shifted;
    color_shifted.r = textureLod(existing_screen_texture, new_uv + vec2(color_distortion_amount, 0.0), 0.0).r;
    color_shifted.g = textureLod(existing_screen_texture, new_uv + vec2(0.0, color_distortion_amount), 0.0).g;
    color_shifted.b = textureLod(existing_screen_texture, new_uv - vec2(color_distortion_amount, color_distortion_amount), 0.0).b;

    // Chromatic Aberration: Offset the RGB channels
    vec3 chromatic_aberration = vec3(0.0);
    chromatic_aberration.r = textureLod(existing_screen_texture, new_uv + vec2(chromatic_aberration_amount, 0.0), 0.0).r;
    chromatic_aberration.g = textureLod(existing_screen_texture, new_uv, 0.0).g;
    chromatic_aberration.b = textureLod(existing_screen_texture, new_uv - vec2(chromatic_aberration_amount, 0.0), 0.0).b;

    // Combine the effects: color distortion + chromatic aberration
    vec3 final_color = color_shifted + chromatic_aberration;

    COLOR.rgb = final_color;
}
