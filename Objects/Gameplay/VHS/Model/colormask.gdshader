shader_type spatial;
render_mode blend_mix, depth_prepass_alpha, cull_back;

uniform sampler2D base_texture;
uniform sampler2D mask_texture;
uniform sampler2D normal_texture : hint_normal;
uniform sampler2D orm_texture;

uniform float alpha_threshold = 0.5;

void fragment() {
    vec4 base_color = texture(base_texture, UV);
    float mask = texture(mask_texture, UV).r;

    ALBEDO = base_color.rgb;
    ALPHA = 1.0 - mask;

    if (ALPHA < alpha_threshold) {
        ALPHA = 0.0;
    }

    // Sample and decode normal map
    vec3 normal_map = texture(normal_texture, UV).rgb;
    normal_map = normal_map * 2.0 - 1.0;

    // Create TBN matrix
    vec3 n = normalize(NORMAL);
    vec3 t = normalize(TANGENT.xyz);
    vec3 b = cross(n, t) * TANGENT.z;
    mat3 tbn = mat3(t, b, n);

    // Transform normal from tangent to world space
    NORMAL = normalize(tbn * normal_map);

    // ORM map: R=AO, G=Roughness, B=Metallic
    vec3 orm = texture(orm_texture, UV).rgb;
    AO = orm.r;
    ROUGHNESS = orm.g;
    METALLIC = orm.b;
}
