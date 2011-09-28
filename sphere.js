var WIDTH = 400;
var HEIGHT = 400;
var VIEW_ANGLE = 45,
	ASPECT = WIDTH / HEIGHT,
	NEAR = 0.1,
	FAR = 10000;

function log(txt) {
	console.log(txt);
}

function init() {

var $container = $('#container');

var renderer = new THREE.WebGLRenderer();
var camera = new THREE.Camera(VIEW_ANGLE, ASPECT, NEAR, FAR);
var scene = new THREE.Scene();

camera.position.z = 300;

renderer.setSize(WIDTH, HEIGHT);

$container.append(renderer.domElement);

	var radius = 50, segments = 16, rings = 16;
	var sphereMaterial = new THREE.MeshLambertMaterial(
		{ color: 0xcc0000 });
	var sphere = new THREE.Mesh(
		new THREE.SphereGeometry(radius, segments, rings),
		sphereMaterial);
	
	scene.addChild(sphere);
	
	renderer.render(scene, camera);
}
