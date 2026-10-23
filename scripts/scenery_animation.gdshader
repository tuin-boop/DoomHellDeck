shader_type canvas_item;
render_mode unshaded;
uniform sampler2D frame_a : source_color, filter_nearest;
uniform sampler2D frame_b : source_color, filter_nearest;
uniform sampler2D eyes : source_color, filter_nearest;
uniform float blend = 0.0;
uniform float lava_strength = 0.0;
uniform float upper_strength = 0.0;
uniform float lower_strength = 0.0;
uniform bool upper_green = false;
uniform bool lower_green = false;

float region(vec2 uv, vec4 bounds) {
	return step(bounds.x,uv.x)*step(bounds.y,uv.y)*step(uv.x,bounds.z)*step(uv.y,bounds.w);
}

void fragment() {
	vec4 base = texture(TEXTURE,UV);
	vec3 animated = mix(texture(frame_a,UV).rgb,texture(frame_b,UV).rgb,blend);
	// Isolate hot pixels, keeping the terrain and buildings completely still.
	float lava_mask = smoothstep(0.25,0.55,animated.r-animated.b)*step(animated.g*0.9,animated.r);
	vec3 result = mix(base.rgb,animated,lava_mask*lava_strength);
	vec3 eye = texture(eyes,UV).rgb;
	// Chroma masks extracted from the supplied green eyes, bounded per skull.
	float eye_mask = smoothstep(0.02,0.4,eye.g-max(eye.r,eye.b));
	float upper = region(UV,vec4(510.0,145.0,550.0,180.0)/vec4(640.0,400.0,640.0,400.0));
	float lower = region(UV,vec4(540.0,270.0,585.0,302.0)/vec4(640.0,400.0,640.0,400.0));
	// White-hot centres are wider than a two-pixel sample. Include their
	// brightness only when surrounded by green, without widening the sockets.
	if (upper+lower>0.0) {
		float nearby_green = 0.0;
		for (int y=-2; y<=2; y++) {
			for (int x=-2; x<=2; x++) {
				vec3 neighbour = texture(eyes,UV+vec2(float(x),float(y))*4.0/vec2(textureSize(eyes,0))).rgb;
				nearby_green = max(nearby_green,smoothstep(0.02,0.4,neighbour.g-max(neighbour.r,neighbour.b)));
			}
		}
		float white_core = smoothstep(0.15,0.5,min(eye.r,min(eye.g,eye.b)));
		eye_mask = max(eye_mask,white_core*nearby_green);
	}
	vec3 red_eye = vec3(eye.g,eye.r*0.3,eye.b*0.2);
	result = mix(result,upper_green ? eye : red_eye,eye_mask*upper*upper_strength);
	result = mix(result,lower_green ? eye : red_eye,eye_mask*lower*lower_strength);
	COLOR = vec4(result,base.a);
}
