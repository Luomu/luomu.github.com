var WIDTH = 400;
var HEIGHT = 400;
var VIEW_ANGLE = 45,
	ASPECT = WIDTH / HEIGHT,
	NEAR = 0.1,
	FAR = 10000;

function log(txt) {
	console.log(txt);
}

requestAnimFrame = window.mozRequestAnimationFrame;

var renderer;
var camera;
var scene;

function init() {

var vsSource = "varying vec3 vNormal;\
	void main() \
	{\
		vNormal = normal;\
		gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);\
	}"

var uniforms = {
	fade: {
		type: 'f',
		value: 0.5
	}
};

var fsSource = "varying vec3 vNormal;\
	uniform float fade;\
	void main()\
	{\
		vec3 light = normalize(vec3(0.5,0.2,1.0));\
		float dProd = max(0.0, dot(vNormal, light));\
		vec3 color = vec3(fade, fade, fade) * dProd;\
		gl_FragColor = vec4(color.r, 0.4, 0.2, 1.0);\
	}"

var $container = $('#container');

renderer = new THREE.WebGLRenderer();
camera = new THREE.Camera(VIEW_ANGLE, ASPECT, NEAR, FAR);
scene = new THREE.Scene();

camera.position.z = 300;

renderer.setSize(WIDTH, HEIGHT);

$container.append(renderer.domElement);

	var radius = 50, segments = 16, rings = 16;
	/*var sphereMaterial = new THREE.MeshLambertMaterial(
		{ color: 0xcc0000 });*/
	scene.sphereMaterial = new THREE.MeshShaderMaterial({
		uniforms: 		uniforms,
		vertexShader: 	vsSource,
		fragmentShader:	fsSource
	});
	var sphere = new THREE.Mesh(
		new THREE.SphereGeometry(radius, segments, rings),
		scene.sphereMaterial);

	scene.addChild(sphere);

	requestAnimFrame(update);
}

var frame = 0;
function update() {
	scene.sphereMaterial.uniforms.fade.value = Math.cos(frame);
	frame += 0.1;
	renderer.render(scene, camera);
	requestAnimFrame(update);
}
