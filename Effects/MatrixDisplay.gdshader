
/******************************************************************************
 * Copyright (c) 2024, xLinka
 * All rights reserved.
 *
 * This shader code is licensed under the GNU General Public License v3.0.
 * For details, see: https://www.gnu.org/licenses/gpl-3.0.html
 *
 * Author: xLinka
 * GitHub: https://www.github.com/xLinka
 *****************************************************************************/

shader_type spatial;

uniform sampler2D albedo_texture : hint_default_black;
uniform vec2 resolution = vec2(64.0, 64.0);
uniform float brightness : hint_range(0.0, 5.0) = 1.5;
uniform float saturation : hint_range(0.0, 2.0) = 0.8;
uniform float border_width : hint_range(0.0, 0.5) = 0.1;
uniform vec3 grid_color : source_color = vec3(0.0, 0.0, 0.0);
uniform float grid_opacity : hint_range(0.0, 1.0) = 0.8;
uniform float led_size : hint_range(0.0, 1.0) = 0.9;

void fragment() {
    vec2 uv = UV;
    
    float lod = textureQueryLod(albedo_texture, uv).x;
    vec2 grid_uv = floor(uv * resolution) / resolution;
    vec4 color = textureLod(albedo_texture, grid_uv, lod);
    color.rgb *= brightness;
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    color.rgb = mix(vec3(gray), color.rgb, saturation);
    vec3 led_color = vec3(0.0);
    vec2 subpixel_offset = fract(uv * resolution * 3.0);

    if (subpixel_offset.x < 0.33) {
        led_color.r = color.r;
    } else if (subpixel_offset.x < 0.66) {
        led_color.g = color.g;
    } else {
        led_color.b = color.b;
    }

    float blur_amount = 0.5 / resolution.x;
    led_color.r = mix(led_color.r, textureLod(albedo_texture, grid_uv + vec2(blur_amount, 0.0), lod).r, 0.5);
    led_color.g = mix(led_color.g, textureLod(albedo_texture, grid_uv + vec2(-blur_amount, 0.0), lod).g, 0.5);
    led_color.b = mix(led_color.b, textureLod(albedo_texture, grid_uv + vec2(0.0, blur_amount), lod).b, 0.5);

    vec2 cellSize = vec2(1.0) / resolution;
    vec2 cellCenter = (floor(uv * resolution) + 0.5) / resolution;
    vec2 distToCenter = abs(uv - cellCenter);

    float grid_mask = 1.0;
    if (distToCenter.x > (0.5 * led_size - border_width) * cellSize.x || distToCenter.y > (0.5 * led_size - border_width) * cellSize.y) {
        grid_mask = grid_opacity;
    }

    ALBEDO = mix(grid_color, led_color, grid_mask);
}
