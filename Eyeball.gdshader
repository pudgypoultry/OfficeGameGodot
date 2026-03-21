shader_type spatial;
// 'render_mode opaque' tells Godot this is a solid object, preventing it from disappearing
render_mode cull_disabled, diffuse_lambert, specular_schlick_ggx;

// --- Texture & Color Parameters ---
uniform sampler2D decal_texture : source_color, filter_linear_mipmap;
uniform float decal_size : hint_range(0.1, 2.0) = 0.5;
uniform vec2 decal_offset = vec2(0.0, 0.0);
uniform vec4 tint_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);

// --- Vein / Wave Parameters ---
uniform float vein_count : hint_range(1.0, 50.0) = 15.0;
uniform float vein_jitter : hint_range(0.0, 10.0) = 2.0;
uniform float vein_width : hint_range(0.001, 0.2) = 0.01;
uniform float vein_length : hint_range(0.1, 1.5) = 0.7;
uniform float vein_speed : hint_range(0.0, 10.0) = 2.0;

varying vec3 local_pos;

// Function: Fast Pseudo-Random Noise
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
	           mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	local_pos = VERTEX;
}

void fragment() {
	// 1. DECAL PROJECTION
	vec2 proj_uv = (local_pos.xy / decal_size) + vec2(0.5) + decal_offset;
	bool is_front = local_pos.z < 0.0;
	bool inside_decal = (proj_uv.x >= 0.0 && proj_uv.x <= 1.0 && proj_uv.y >= 0.0 && proj_uv.y <= 1.0);

	// 2. FRACTAL VEIN LOGIC
	float angle = atan(local_pos.y, local_pos.x);
	float noise_large = noise(vec2(angle * 1.5, local_pos.z * 2.0 + TIME * (vein_speed * 0.2)));
	float noise_fine = noise(vec2(angle * 8.0, local_pos.z * 10.0 + TIME * vein_speed));
	float combined_distortion = (noise_large * 2.5) + (noise_fine * vein_jitter * 0.5);
	
	float pattern = sin(angle * vein_count + combined_distortion);
	
	// Sharpness calculation
	float vein_mask = pow(1.0 - abs(pattern), 12.0 / (vein_width * 100.0));
	float vein_fade = clamp((-local_pos.z + (vein_length - 0.5)), 0.0, 1.0);
	float final_vein = clamp(vein_mask * vein_fade, 0.0, 1.0);

	// 3. COLOR ASSEMBLY
	vec3 white_base = vec3(1.0);
	vec3 veiny_surface = mix(white_base, tint_color.rgb, final_vein);

	vec3 final_color;
	if (is_front && inside_decal) {
		vec4 tex = texture(decal_texture, proj_uv);
		float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
		
		// If the texture is transparent (alpha) or white (lum), show the veiny background
		// We use a threshold for alpha to keep it strictly opaque
		if (tex.a < 0.2 || lum > 0.9) {
			final_color = veiny_surface;
		} else {
			final_color = tex.rgb;
		}
	} else {
		final_color = veiny_surface;
	}

	ALBEDO = final_color;
	// FORCE ALPHA TO 1.0 to prevent transparency issues in play mode
	ALPHA = 1.0; 
}