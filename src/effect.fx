
// Sample WebGL 1 shader. This just outputs a red color
// to indicate WebGL 1 is in use.

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

float sdRoundRect( vec2 p, vec2 s, float r )
{
    vec2 d = abs(p) - s + r;
    return min(max(d.x,d.y),0.0) + length(max(d,0.0)) - r;
}

void main(void)
{
    vec2 uv = (vTex - srcOriginStart) / (srcOriginEnd - srcOriginStart);

    // Calculate the layout size
    mediump vec2 layoutSize = abs(vec2(layoutEnd.x-layoutStart.x, (layoutEnd.y-layoutStart.y))); 

    vec2 center = vec2(0.5) * layoutSize;
    vec2 n = (uv * layoutSize - center); // shifts the origin to the center and transforms to texel space

    // Apply rotation
    float rad = angle * 3.14159265 / 180.0;
    float cosAngle = cos(-rad);
    float sinAngle = sin(-rad);
    n = vec2(n.x * cosAngle - n.y * sinAngle, n.x * sinAngle + n.y * cosAngle);

    // scaling factor to make sure the rectangle inscribed inside the render rectangle area
    float scaleFactor = 1.0 / sqrt(2.0);
    vec2 size = vec2(width, height) * vec2(0.5); // Scaled size

    float radiusInTexels = min(max(0.0, radius), min(size.x, size.y)); // Radius in texels

    float d = sdRoundRect(n, size, radiusInTexels);
		vec4 clearColor = vec4(0.0,0.0,0.0,0.0);
    vec4 texColor = texture2D(samplerFront, vTex);
    gl_FragColor = mix(texColor, clearColor, step(0.0, d));
}
