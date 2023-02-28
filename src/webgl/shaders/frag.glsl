precision highp float;

uniform sampler2D uTex;
uniform sampler2D uTexHover;
uniform sampler2D uTexPaper;
uniform sampler2D tMap;
uniform vec2 uMouse;
uniform vec2 uRes;
uniform float uTime;

varying vec2 vUv;

float circle(in vec2 _st, in float _radius, in float blurriness){
	vec2 dist = _st;
	return 1.-smoothstep(_radius-(_radius*blurriness), _radius+(_radius*blurriness), dot(dist,dist)*4.0);
}

//	Simplex 3D Noise 
//	by Ian McEwan, Ashima Arts
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}

float snoise(vec3 v){ 
	const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
	const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

	// First corner
	vec3 i  = floor(v + dot(v, C.yyy) );
	vec3 x0 =   v - i + dot(i, C.xxx) ;

	// Other corners
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );

	//  x0 = x0 - 0. + 0.0 * C 
	vec3 x1 = x0 - i1 + 1.0 * C.xxx;
	vec3 x2 = x0 - i2 + 2.0 * C.xxx;
	vec3 x3 = x0 - 1. + 3.0 * C.xxx;

	// Permutations
	i = mod(i, 289.0 ); 
	vec4 p = permute( permute( permute( 
				i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
			+ i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
			+ i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

	// Gradients
	// ( N*N points uniformly over a square, mapped onto an octahedron.)
	float n_ = 1.0/7.0; // N=7
	vec3  ns = n_ * D.wyz - D.xzx;

	vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)

	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

	vec4 x = x_ *ns.x + ns.yyyy;
	vec4 y = y_ *ns.x + ns.yyyy;
	vec4 h = 1.0 - abs(x) - abs(y);

	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );

	vec4 s0 = floor(b0)*2.0 + 1.0;
	vec4 s1 = floor(b1)*2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));

	vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
	vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

	vec3 p0 = vec3(a0.xy,h.x);
	vec3 p1 = vec3(a0.zw,h.y);
	vec3 p2 = vec3(a1.xy,h.z);
	vec3 p3 = vec3(a1.zw,h.w);

	//Normalise gradients
	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	// Mix final noise value
	vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) );
}


#define NUM_OCTAVES 5

float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < NUM_OCTAVES; ++i) {
	v += a * snoise(x);
	x = x * 2.0 + shift;
	a *= 0.5;
	}
	return v;
}

void main() {
	vec4 color = texture2D(tMap, vUv) * 0.95;
	vec4 video = texture2D(uTex, vUv);
	vec4 hover = texture2D(uTexHover, vUv);
	vec4 paper = texture2D(uTexPaper,vUv);

	// We manage the device ratio by passing PR constant
	vec2 res = uRes * PR;
	vec2 st = gl_FragCoord.xy / res.xy - vec2(0.5);
	// Use the following formula to keep the good ratio of your coordinates
	st.y *= uRes.y / uRes.x;

	// We readjust the mouse coordinates
	vec2 mouse = uMouse * -0.5;
	mouse.y *= uRes.y / uRes.x;

	vec2 maskPos = st + mouse;

	float dist = length(maskPos);

	if(dist + (fbm(vec3(vUv *15.,1.0)) * 0.2 * dist) < 0.07) {
		float falloff = smoothstep(0.15, 0.1, dist);
		color.r=mix(color.r, 1., falloff);
	}


	if(dist + (fbm(vec3(vUv *15.,0.0)) * 0.2 * dist) < 0.08) {
		float falloff = smoothstep(0.15, 0.1, dist);
		color.b=mix(color.b, 1., falloff);
	}

	// vec4 finalImage = mix( video, hover , color);
	vec3 finalImage = mix( video.rgb, mix( paper.rgb , hover.rgb, min(1.,color.r * color.r * 10.)), min(1.,color.b * color.b * 10.));

	gl_FragColor = vec4(finalImage,1.);
}