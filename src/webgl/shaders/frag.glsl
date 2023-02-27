precision highp float;

uniform sampler2D uTex;
uniform sampler2D uTexHover;
uniform sampler2D uMask;
uniform vec2 uMouse;
uniform vec2 uRes;
uniform float uTime;

varying vec2 vUv;

void main() {
	vec4 video = texture2D(uTex, vUv);
	vec4 hover = texture2D(uTexHover, vUv);

	// We manage the device ratio by passing PR constant
	vec2 res = uRes * PR;
	vec2 st = gl_FragCoord.xy / res.xy - vec2(0.5);
	// Use the following formula to keep the good ratio of your coordinates
	st.y *= uRes.y / uRes.x;

	// We readjust the mouse coordinates
	vec2 mouse = uMouse * -0.5;
	mouse.y *= uRes.y / uRes.x;

	vec2 maskPos = st + mouse + 0.5;

  // Mask
  vec4 _Mask = texture2D(uMask, maskPos);

	vec4 finalImage = mix(video, hover, _Mask);

	// Add Paper effect
	gl_FragColor = finalImage;
}