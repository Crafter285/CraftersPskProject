shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D emission_mask : source_color; 
uniform sampler2D flow_noise : repeat_enable;    
uniform vec4 glow_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform float flow_speed : hint_range(-5.0, 5.0) = 1.0;
uniform float intensity : hint_range(0.0, 30.0) = 10.0;

uniform float fresnel_power : hint_range(0.1, 10.0) = 3.0;
uniform float base_alpha : hint_range(0.0, 1.0) = 0.2;
uniform float edge_intensity : hint_range(0.0, 5.0) = 1.5;

void fragment() {
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), fresnel_power);
    
    vec2 moving_uv = UV * vec2(1.0, 4.0);
    moving_uv.y -= TIME * flow_speed;
    
    float n1 = texture(flow_noise, moving_uv).r;
    float n2 = texture(flow_noise, moving_uv * 1.2 + vec2(0.3, 0.2)).r;
    float liquid = pow(n1 * n2, 2.0) * 5.0;

    float mask = texture(emission_mask, UV).r;

    float combined_glow = (liquid + (fresnel * edge_intensity)) * mask;
    
    ALBEDO = glow_color.rgb; 
    
    ALPHA = clamp(base_alpha + combined_glow, 0.0, 1.0) * mask;
    
    EMISSION = glow_color.rgb * combined_glow * intensity;
    
    ROUGHNESS = 0.1;
    METALLIC = 0.5;
}