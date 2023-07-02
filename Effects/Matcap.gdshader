/******************************************************************************
 * Copyright (c) 2023, xLinka
 * All rights reserved.
 *
 * This shader code is licensed under the GNU General Public License v3.0.
 * For details, see: https://www.gnu.org/licenses/gpl-3.0.html
 *
 * Author: xLinka
 * GitHub: https://www.github.com/xLinka
 *****************************************************************************/

shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo_texture : hint_default_transparent;
uniform sampler2D matcap_texture : hint_default_white;

void fragment() {
    // Get the normal of the fragment
    vec3 normal = normalize(NORMAL);

    // Calculate the reflection vector using the normal and the view vector
    vec3 viewDir = normalize(VIEW);
    vec3 reflection = reflect(-viewDir, normal);

    // Sample the matcap texture using the reflection vector
    vec4 matcapColor = texture(matcap_texture, reflection.xy * 0.5 + 0.5);

    // Sample the albedo texture
    vec4 albedoColor = texture(albedo_texture, UV);

    // Apply the matcap effect to the albedo color
    vec3 finalColor = matcapColor.rgb * albedoColor.rgb;

    // Set the final color of the fragment
    ALBEDO = finalColor;
    EMISSION = vec3(0.0);
}
