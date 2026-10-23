shader_type canvas_item;
uniform float source_pixels_per_screen_pixel = 2.0;
void fragment() {
 vec4 base = texture(TEXTURE, UV);
 vec2 outer_step = TEXTURE_PIXEL_SIZE * source_pixels_per_screen_pixel * 3.0;
 vec2 inner_step = TEXTURE_PIXEL_SIZE * source_pixels_per_screen_pixel * 1.5;
 float outer_alpha = base.a;
 float inner_alpha = base.a;
 for (int i=0; i<16; i++) {
  float angle = float(i)*6.2831853/16.0;
  vec2 direction = vec2(cos(angle),sin(angle));
  outer_alpha = max(outer_alpha, texture(TEXTURE, UV+direction*outer_step).a);
  inner_alpha = min(inner_alpha, texture(TEXTURE, UV+direction*inner_step).a);
 }
 // Darken inward from the alpha silhouette to cover light matte fringes.
 float edge = 1.0-smoothstep(0.05,0.95,inner_alpha);
 vec3 rgb = mix(base.rgb,vec3(0.0),edge);
 float alpha = max(base.a,outer_alpha);
 COLOR = vec4(rgb*base.a/max(alpha,0.001),alpha);
}
