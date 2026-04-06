shader_type spatial;

// MultiColor textures
uniform sampler2D color_palette : source_color;  // T_MultiColor_BC_A
uniform sampler2D roughness_map;                 // T_MultiColor_R_A
uniform float color_index_x : hint_range(0.0, 1.0) = 0.0;
uniform float color_index_y : hint_range(0.0, 1.0) = 0.0;

// Other texture's BC and ORMK
uniform sampler2D albedo_texture : source_color; // other _BC
uniform sampler2D ormk_texture;                  // other _ORMK

void fragment() {
    // Sample the color swatch
    vec4 palette_color = texture(color_palette, vec2(color_index_x, color_index_y));
    
    // Sample the base color texture
    vec4 albedo = texture(albedo_texture, UV);
    
    // Unpack ORMK channels
    vec4 ormk = texture(ormk_texture, UV);
    float occlusion = ormk.r;
    float roughness = ormk.g;
    float metallic  = ormk.b;
    // ormk.a is the K mask - can be used to blend multicolor vs base texture
    
    // Use K mask to blend between palette color and base albedo
    vec3 final_color = mix(albedo.rgb, palette_color.rgb, ormk.a);
    
    // Also pull roughness from MultiColor_R where the K mask applies
    float multi_roughness = texture(roughness_map, UV).r;
    float final_roughness = mix(roughness, multi_roughness, ormk.a);
    
    ALBEDO = final_color * occlusion; // AO darkens the color
    ROUGHNESS = final_roughness;
    METALLIC = metallic;
    AO = occlusion;
    AO_LIGHT_AFFECT = 1.0;
}