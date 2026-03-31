shader_type spatial;
render_mode unshaded, cull_back;

uniform sampler2D texture_albedo : source_color, hint_default_white;
uniform vec4 glow_color : source_color = vec4(0.5, 0.0, 1.0, 1.0);
uniform float black_threshold : hint_range(0.0, 1.0) = 0.1;
uniform float fade_speed : hint_range(0.1, 10.0) = 3.0;

uniform float current_alpha = 0.0;

void fragment() {
    vec4 tex = texture(texture_albedo, UV);
    float brightness = max(tex.r, max(tex.g, tex.b));
    float alpha = smoothstep(black_threshold, black_threshold + 0.1, brightness);

    ALBEDO = tex.rgb;
    EMISSION = tex.rgb * glow_color.rgb;
    ALPHA = alpha * current_alpha;
}