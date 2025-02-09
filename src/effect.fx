#ifdef GL_FRAGMENT_PRECISION_HIGH
#define highmedp highp
#else
#define highmedp mediump
#endif

precision lowp float;

varying mediump vec2 vTex;
uniform lowp sampler2D samplerFront;
uniform mediump vec2 srcStart;
uniform mediump vec2 srcEnd;
uniform mediump vec2 srcOriginStart;
uniform mediump vec2 srcOriginEnd;
uniform mediump vec2 layoutStart;
uniform mediump vec2 layoutEnd;
uniform lowp sampler2D samplerBack;
uniform lowp sampler2D samplerDepth;
uniform mediump vec2 destStart;
uniform mediump vec2 destEnd;
uniform highmedp float seconds;
uniform mediump vec2 pixelSize;
uniform mediump float layerScale;
uniform mediump float layerAngle;
uniform mediump float devicePixelRatio;
uniform mediump float zNear;
uniform mediump float zFar;

//<-- UNIFORMS -->

vec4 rescaleCornerRadii(vec4 cr, vec2 rt) {
    float maxWidth = rt.x;
    float maxHeight = rt.y;

    // Compute total radii for each axis
    float totalTop = cr.x + cr.y;
    float totalBottom = cr.z + cr.w;
    float totalLeft = cr.y + cr.w;
    float totalRight = cr.x + cr.z;

    // Scale factor to keep ratios the same if they exceed dimensions
    float scaleTop = totalTop > maxWidth ? maxWidth / totalTop : 1.0;
    float scaleBottom = totalBottom > maxWidth ? maxWidth / totalBottom : 1.0;
    float scaleLeft = totalLeft > maxHeight ? maxHeight / totalLeft : 1.0;
    float scaleRight = totalRight > maxHeight ? maxHeight / totalRight : 1.0;

    return vec4(
        min(cr.x * scaleTop, cr.x * scaleRight),  // Top-right
        min(cr.y * scaleTop, cr.y * scaleLeft),   // Top-left
        min(cr.z * scaleBottom, cr.z * scaleRight), // Bottom-right
        min(cr.w * scaleBottom, cr.w * scaleLeft)  // Bottom-left
    );
}

// Round the top-right corner
float roundedTopRight(vec2 pos, vec2 rt, float cr) {
    vec2 halfSize = rt * 0.5;
    if (pos.x < halfSize.x - cr || pos.y < halfSize.y - cr) return 1.0;
    vec2 cornerCenter = vec2(halfSize.x - cr, halfSize.y - cr);
    return smoothstep(cr, cr - 1.0, length(pos - cornerCenter));
}

// Round the top-left corner
float roundedTopLeft(vec2 pos, vec2 rt, float cr) {
    vec2 halfSize = rt * 0.5;
    if (pos.x > -halfSize.x + cr || pos.y < halfSize.y - cr) return 1.0;
    vec2 cornerCenter = vec2(-halfSize.x + cr, halfSize.y - cr);
    return smoothstep(cr, cr - 1.0, length(pos - cornerCenter));
}

// Round the bottom-right corner
float roundedBottomRight(vec2 pos, vec2 rt, float cr) {
    vec2 halfSize = rt * 0.5;
    if (pos.x < halfSize.x - cr || pos.y > -halfSize.y + cr) return 1.0;
    vec2 cornerCenter = vec2(halfSize.x - cr, -halfSize.y + cr);
    return smoothstep(cr, cr - 1.0, length(pos - cornerCenter));
}

// Round the bottom-left corner
float roundedBottomLeft(vec2 pos, vec2 rt, float cr) {
    vec2 halfSize = rt * 0.5;
    if (pos.x > -halfSize.x + cr || pos.y > -halfSize.y + cr) return 1.0;
    vec2 cornerCenter = vec2(-halfSize.x + cr, -halfSize.y + cr);
    return smoothstep(cr, cr - 1.0, length(pos - cornerCenter));
}

float sdRoundRect(vec2 pos, vec2 rt, vec4 cr) {
    vec4 scaledCr = rescaleCornerRadii(cr, rt);
    vec2 halfSize = rt * 0.5;

    // Ensure the position is inside the main rectangle bounds
    if (abs(pos.x) >= halfSize.x || abs(pos.y) >= halfSize.y) {
        return 0.0;
    }

    // Check each rounded corner
    float topRight = roundedTopRight(pos, rt, scaledCr.x);
    float topLeft = roundedTopLeft(pos, rt, scaledCr.y);
    float bottomRight = roundedBottomRight(pos, rt, scaledCr.z);
    float bottomLeft = roundedBottomLeft(pos, rt, scaledCr.w);

    // Take the min of all four functions, ensuring all corners are correctly applied
    return min(min(topRight, topLeft), min(bottomRight, bottomLeft));
}



void main(void) {
    vec2 uv = (vTex - srcOriginStart) / (srcOriginEnd - srcOriginStart);

    // Calculate the layout size
    mediump vec2 layoutSize = abs(vec2(layoutEnd.x - layoutStart.x, layoutEnd.y - layoutStart.y));

    vec2 center = vec2(0.5) * layoutSize;
    vec2 n = (uv * layoutSize - center); // shifts the origin to the center and transforms to texel space

    // Apply rotation
    float rad = angle  * 3.14159265 / 180.0;
    float cosAngle = cos(-rad);
    float sinAngle = sin(-rad);
    n = vec2(n.x * cosAngle - n.y * sinAngle, n.x * sinAngle + n.y * cosAngle);

    // Scaling factor to fit within render rectangle area
    float scaleFactor = 1.0 / sqrt(2.0);
    vec2 size =  vec2(width, height); // Scaled size
    float defaultRadius = max(radius, 0.0);

    vec4 radii = vec4(
        radiusBR > 0.0 ? radiusBR : defaultRadius,
        radiusBL > 0.0 ? radiusBL : defaultRadius,
        radiusTR > 0.0 ? radiusTR : defaultRadius,
        radiusTL > 0.0 ? radiusTL : defaultRadius
    );

    // Signed distance function with individual corner radii
    float d = sdRoundRect(n, size, radii);

    vec4 clearColor = vec4(0.0, 0.0, 0.0, 0.0);
    vec4 texColor = texture2D(samplerFront, vTex);
    gl_FragColor = mix(clearColor, texColor, smoothstep(0.0, 0.01, d));
}
