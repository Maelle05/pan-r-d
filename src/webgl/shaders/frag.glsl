precision highp float;

uniform sampler2D uTex;
uniform sampler2D uTexHover;
uniform vec2 uMouse;
uniform vec2 uRes;

varying vec2 vUv;

float circle(in vec2 _st, in float _radius, in float blurriness){
	vec2 dist = _st;
	return 1.-smoothstep(_radius-(_radius*blurriness), _radius+(_radius*blurriness), dot(dist,dist)*4.0);
}

void main() {
  vec4 video = texture2D(uTex, vUv);
  vec4 hover = texture2D(uTexHover, vUv);

  // We manage the device ratio by passing PR constant
	vec2 res = uRes;
	vec2 st = gl_FragCoord.xy / res.xy - vec2(0.5);
	// tip: use the following formula to keep the good ratio of your coordinates
	st.y *= uRes.y / uRes.x;

	// We readjust the mouse coordinates
	vec2 mouse = uMouse * -0.5;
	// tip2: do the same for your mouse
	mouse.y *= uRes.y / uRes.x;
	mouse *= -1.;

	vec2 circlePos = st + mouse;
  float c = circle(circlePos, 0.03, 2.) * 2.5;

  float finalMask = smoothstep(0.4, 0.5, c);
  vec4 finalImage = mix(video, hover, finalMask);

  gl_FragColor = finalImage;
}