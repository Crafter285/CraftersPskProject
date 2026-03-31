shader_type spatial;
render_mode depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

// ── Textures ──────────────────────────────────────────────────────────────────
uniform sampler2D texture_albedo : source_color, hint_default_white;
uniform sampler2D texture_orm    : hint_default_white;   // G = roughness, B = metallic
uniform sampler2D texture_normal : hint_normal;
uniform float     normal_scale   : hint_range(0.0, 4.0) = 1.0;

// ── Burn controls ─────────────────────────────────────────────────────────────
uniform float burn_progress        : hint_range(0.0, 1.2)   = 0.0;
uniform float ember_width          : hint_range(0.01, 0.25) = 0.06;
uniform float ember_glow_intensity : hint_range(0.0, 8.0)   = 5.0;
uniform float noise_scale          : hint_range(1.0, 30.0)  = 10.0;
uniform float noise_strength       : hint_range(0.0, 0.25)  = 0.07;

// ── Burn colours ──────────────────────────────────────────────────────────────
uniform vec4 char_color  : source_color = vec4(0.07, 0.05, 0.04, 1.0);
uniform vec4 ember_color : source_color = vec4(1.00, 0.32, 0.02, 1.0);
uniform vec4 ash_color   : source_color = vec4(0.28, 0.26, 0.24, 1.0);

// ─────────────────────────────────────────────────────────────────────────────
float hash(vec2 p) {
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}
float smoothNoise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    f = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i),                  hash(i + vec2(1.0, 0.0)), f.x),
        mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x),
        f.y);
}
// ─────────────────────────────────────────────────────────────────────────────

void fragment() {
    vec2 uv = UV;

    // ── Sample textures ───────────────────────────────────────────────────────
    vec3  albedo    = texture(texture_albedo, uv).rgb;
    vec4  orm       = texture(texture_orm, uv);
    float roughness = orm.g;
    float metallic  = orm.b;

    NORMAL_MAP       = texture(texture_normal, uv).rgb;
    NORMAL_MAP_DEPTH = normal_scale;

    // ── Burn math ─────────────────────────────────────────────────────────────
    float n1 = smoothNoise(uv * noise_scale)                         * 2.0 - 1.0;
    float n2 = smoothNoise(uv * noise_scale * 2.3 + vec2(5.1, 3.7)) * 2.0 - 1.0;
    float noise_offset = (n1 * 0.6 + n2 * 0.4) * noise_strength;

    float burn_pos    = uv.y + noise_offset;
    float before_burn = burn_progress - burn_pos;
    float past_burn   = burn_pos - burn_progress;

    // Is burning active at all?
    float burning = step(0.001, burn_progress);

    // Discard pixels that have burned away (only when burn is active)
    if (burning > 0.5 && before_burn > ember_width * 0.6) {
        discard;
    }

    // Zone weights — all zeroed out when burn_progress == 0
    float ember_zone   = burning * smoothstep(0.0, ember_width, before_burn)
                                 * smoothstep(ember_width * 1.6, 0.0, before_burn);
    float is_charred   = burning * step(0.0, before_burn)
                                 * (1.0 - step(ember_width * 0.6, before_burn));
    float preheat_zone = burning * smoothstep(0.0,  -0.025, past_burn)
                                 * smoothstep(-0.05,  0.0,   past_burn);

    // ── Colour blending ───────────────────────────────────────────────────────
    vec3 col = albedo;
    col = mix(col, col * 0.70,    preheat_zone * 0.6);
    col = mix(col, char_color.rgb, is_charred);
    float ash_n = smoothNoise(uv * noise_scale * 0.5 + vec2(1.3, 2.7));
    col = mix(col, ash_color.rgb,  is_charred * ash_n * 0.5);
    col = mix(col, ember_color.rgb, ember_zone);

    // ── Emission ──────────────────────────────────────────────────────────────
    float flicker = 0.82 + 0.18 * sin(TIME * 20.0 + uv.x * 35.0 + n1 * 7.0);
    vec3 emission = ember_color.rgb * ember_zone * ember_glow_intensity * flicker;
    emission     += ember_color.rgb * preheat_zone * 0.3;

    // ── PBR overrides in burn zones ───────────────────────────────────────────
    roughness = mix(roughness, 0.95, is_charred);
    roughness = mix(roughness, 0.60, ember_zone);
    metallic  = mix(metallic,  0.0,  max(is_charred, ember_zone));

    ALBEDO    = col;
    EMISSION  = emission;
    ROUGHNESS = roughness;
    METALLIC  = metallic;
}