shader_type spatial;

uniform float speed = 1.0;         // Speed of the electricity animation
uniform float thickness = 0.2;     // Thickness of the glowing spiral
uniform float glow_intensity = 4.0; // Strength of the glow effect
uniform vec3 glow_color = vec3(0.0, 0.7, 1.5); // Electric blue color
uniform float flow_direction = 1.0; // 1.0 for forward, -1.0 for reverse
uniform float spiral_density = 10.0; // Controls how tight the spirals are
uniform float power_on = 1.0;       // 1.0 = On, 0.0 = Off (toggle power)

void fragment() {
    // UV coordinates
    vec2 uv = UV;

    // Convert UV into cylindrical coordinates (assuming a TubeMesh)
    float angle = atan(uv.y - 0.5, uv.x - 0.5); // Get angular position

    // Apply spiral density and movement
    float spiral = mod(angle + TIME * speed * flow_direction, 6.283);

    // Control how spread out the spirals are
    float glow = smoothstep(0.5 - thickness, 0.5 + thickness, sin(spiral * spiral_density));

    // Smooth transition when turning on/off
    glow *= smoothstep(0.0, 1.0, power_on);

    // Base black color (cable stays visible)
    vec3 base_color = vec3(0.0);

    // Final color with emission
    vec3 final_color = base_color + glow * glow_color * glow_intensity;

    // Assign colors
    ALBEDO = final_color;
    EMISSION = glow * glow_color * glow_intensity;
}
