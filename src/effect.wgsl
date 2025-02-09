/////////////////////////////////////////////////////////
// Minimal sample WebGPU shader. This just outputs a blue
// color to indicate WebGPU is in use (rather than one of
// the WebGL shader variants).

%%FRAGMENTINPUT_STRUCT%%
/* input struct contains the following fields:
fragUV : vec2<f32>
fragPos : vec4<f32>
fn c3_getBackUV(fragPos : vec2<f32>, texBack : texture_2d<f32>) -> vec2<f32>
fn c3_getDepthUV(fragPos : vec2<f32>, texDepth : texture_depth_2d) -> vec2<f32>
*/
%%FRAGMENTOUTPUT_STRUCT%%

%%SAMPLERFRONT_BINDING%% var samplerFront : sampler;
%%TEXTUREFRONT_BINDING%% var textureFront : texture_2d<f32>;

//%//%SAMPLERBACK_BINDING%//% var samplerBack : sampler;
//%//%TEXTUREBACK_BINDING%//% var textureBack : texture_2d<f32>;

//%//%SAMPLERDEPTH_BINDING%//% var samplerDepth : sampler;
//%//%TEXTUREDEPTH_BINDING%//% var textureDepth : texture_depth_2d;

/* Uniforms are:
uAngle: angle of the shine, 0.0-360.0
uIntensity: how hard to mix the shine with the image, 0.0-1.0
uColor: the color of the shine, vec4
uSize: the size of the shine in percent based on diameter, 0.0-1.0
uProgress: the progress of the shine, 0.0-1.0
uHardness: how hard the shine is, 0 is smooth, 1 is a hard edge , 0.0-1.0
 */

//<-- shaderParams -->
/* gets replaced with:

struct ShaderParams {

	floatParam : f32,
	colorParam : vec3<f32>,
	// etc.

};

%//%SHADERPARAMS_BINDING%//% var<uniform> shaderParams : ShaderParams;
*/


%%C3PARAMS_STRUCT%%
/* c3Params struct contains the following fields:
srcStart : vec2<f32>,
srcEnd : vec2<f32>,
srcOriginStart : vec2<f32>,
srcOriginEnd : vec2<f32>,
layoutStart : vec2<f32>,
layoutEnd : vec2<f32>,
destStart : vec2<f32>,
destEnd : vec2<f32>,
devicePixelRatio : f32,
layerScale : f32,
layerAngle : f32,
seconds : f32,
zNear : f32,
zFar : f32,
isSrcTexRotated : u32
fn c3_srcToNorm(p : vec2<f32>) -> vec2<f32>
fn c3_normToSrc(p : vec2<f32>) -> vec2<f32>
fn c3_srcOriginToNorm(p : vec2<f32>) -> vec2<f32>
fn c3_normToSrcOrigin(p : vec2<f32>) -> vec2<f32>
fn c3_clampToSrc(p : vec2<f32>) -> vec2<f32>
fn c3_clampToSrcOrigin(p : vec2<f32>) -> vec2<f32>
fn c3_getLayoutPos(p : vec2<f32>) -> vec2<f32>
fn c3_srcToDest(p : vec2<f32>) -> vec2<f32>
fn c3_clampToDest(p : vec2<f32>) -> vec2<f32>
fn c3_linearizeDepth(depthSample : f32) -> f32
*/

//%//%C3_UTILITY_FUNCTIONS%//%
/*
fn c3_premultiply(c : vec4<f32>) -> vec4<f32>
fn c3_unpremultiply(c : vec4<f32>) -> vec4<f32>
fn c3_grayscale(rgb : vec3<f32>) -> f32
fn c3_getPixelSize(t : texture_2d<f32>) -> vec2<f32>
fn c3_RGBtoHSL(color : vec3<f32>) -> vec3<f32>
fn c3_HSLtoRGB(hsl : vec3<f32>) -> vec3<f32>
*/

fn rescaleCornerRadii(cr: vec4<f32>, rt: vec2<f32>) -> vec4<f32> {
    let maxWidth = rt.x;
    let maxHeight = rt.y;

    let totalTop = cr.x + cr.y;
    let totalBottom = cr.z + cr.w;
    let totalLeft = cr.y + cr.w;
    let totalRight = cr.x + cr.z;

    let scaleTop = select(1.0, maxWidth / totalTop, totalTop > maxWidth);
		let scaleBottom = select(1.0, maxWidth / totalBottom, totalBottom > maxWidth);
		let scaleLeft = select(1.0, maxHeight / totalLeft, totalLeft > maxHeight);
		let scaleRight = select(1.0, maxHeight / totalRight, totalRight > maxHeight);

    return vec4<f32>(
        min(cr.x * scaleTop, cr.x * scaleRight),
        min(cr.y * scaleTop, cr.y * scaleLeft),
        min(cr.z * scaleBottom, cr.z * scaleRight),
        min(cr.w * scaleBottom, cr.w * scaleLeft)
    );
}

fn roundedTopRight(pos: vec2<f32>, rt: vec2<f32>, cr: f32) -> f32 {
    let halfSize = rt * 0.5;
    if (pos.x < halfSize.x - cr || pos.y < halfSize.y - cr) {
        return 1.0;
    }
    let cornerCenter = vec2<f32>(halfSize.x - cr, halfSize.y - cr);
    return smoothstep(cr, cr - 1.0, length(pos - cornerCenter));
}

fn roundedTopLeft(pos: vec2<f32>, rt: vec2<f32>, cr: f32) -> f32 {
    let halfSize = rt * 0.5;
    if (pos.x > -halfSize.x + cr || pos.y < halfSize.y - cr) {
        return 1.0;
    }
    let cornerCenter = vec2<f32>(-halfSize.x + cr, halfSize.y - cr);
    return smoothstep(cr, cr - 1.0, length(pos - cornerCenter));
}

fn roundedBottomRight(pos: vec2<f32>, rt: vec2<f32>, cr: f32) -> f32 {
    let halfSize = rt * 0.5;
    if (pos.x < halfSize.x - cr || pos.y > -halfSize.y + cr) {
        return 1.0;
    }
    let cornerCenter = vec2<f32>(halfSize.x - cr, -halfSize.y + cr);
    return smoothstep(cr, cr - 1.0, length(pos - cornerCenter));
}

fn roundedBottomLeft(pos: vec2<f32>, rt: vec2<f32>, cr: f32) -> f32 {
    let halfSize = rt * 0.5;
    if (pos.x > -halfSize.x + cr || pos.y > -halfSize.y + cr) {
        return 1.0;
    }
    let cornerCenter = vec2<f32>(-halfSize.x + cr, -halfSize.y + cr);
    return smoothstep(cr, cr - 1.0, length(pos - cornerCenter));
}

fn sdRoundRect(pos: vec2<f32>, rt: vec2<f32>, cr: vec4<f32>) -> f32 {
    let scaledCr = rescaleCornerRadii(cr, rt);
    let halfSize = rt * 0.5;

    if (abs(pos.x) >= halfSize.x || abs(pos.y) >= halfSize.y) {
        return 0.0;
    }

    let topRight = roundedTopRight(pos, rt, scaledCr.x);
    let topLeft = roundedTopLeft(pos, rt, scaledCr.y);
    let bottomRight = roundedBottomRight(pos, rt, scaledCr.z);
    let bottomLeft = roundedBottomLeft(pos, rt, scaledCr.w);

    return min(min(topRight, topLeft), min(bottomRight, bottomLeft));
}


@fragment
fn main(input: FragmentInput) -> FragmentOutput {
    let uv = (input.fragUV - c3Params.srcOriginStart) / (c3Params.srcOriginEnd - c3Params.srcOriginStart);

    // Calculate the layout size
    let layoutSize = abs(vec2<f32>(c3Params.layoutEnd.x - c3Params.layoutStart.x, c3Params.layoutEnd.y - c3Params.layoutStart.y));
    let center = vec2<f32>(0.5) * layoutSize;
    let n = (uv * layoutSize - center); // shifts the origin to the center and transforms to texel space

    // Apply rotation
    let rad = shaderParams.angle * 3.14159265 / 180.0;
    let cosAngle = cos(-rad);
    let sinAngle = sin(-rad);
    let transformed = vec2<f32>(n.x * cosAngle - n.y * sinAngle, n.x * sinAngle + n.y * cosAngle);

    // Scaling factor to fit within the render area
    let scaleFactor = 1.0 / sqrt(2.0);
    let size = vec2<f32>(shaderParams.width, shaderParams.height); // Scaled size
    let defaultRadius = max(shaderParams.radius, 0.0);

		let radii = vec4<f32>(
			select(defaultRadius, shaderParams.radiusBR, shaderParams.radiusBR > 0.0),
			select(defaultRadius, shaderParams.radiusBL, shaderParams.radiusBL > 0.0),
			select(defaultRadius, shaderParams.radiusTR, shaderParams.radiusTR > 0.0),
			select(defaultRadius, shaderParams.radiusTL, shaderParams.radiusTL > 0.0)
    );

    // Compute signed distance function with individual corner radii
    let d = sdRoundRect(transformed, size, radii);

    let clearColor = vec4<f32>(0.0, 0.0, 0.0, 0.0);
    let texColor = textureSample(textureFront, samplerFront, input.fragUV);

    var output: FragmentOutput;
    output.color = mix(clearColor, texColor, smoothstep(0.0, 0.01, d));
    return output;
}
