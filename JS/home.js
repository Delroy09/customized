let scene, camera, renderer, model;
let rotationSpeed = 0.05; // Initial rotation speed
let isSpinning = true;

function init() {
    // Scene setup
    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000);
    camera.position.set(0, 0, 10); // Move camera back

    // Renderer setup
    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setSize(600, 600, false);
    renderer.setPixelRatio(window.devicePixelRatio);
    renderer.setClearColor(0xF0F0F0, 0);
    document.getElementById("model-container").appendChild(renderer.domElement);

    // Enhanced lighting
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);

    const directionalLight = new THREE.DirectionalLight(0xffffff, 1);
    directionalLight.position.set(5, 5, 5);
    scene.add(directionalLight);

    // Controls
    const controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.screenSpacePanning = false;

    // Debug helpers
    const axesHelper = new THREE.AxesHelper(5);
    scene.add(axesHelper);

    const gridHelper = new THREE.GridHelper(10, 10);
    scene.add(gridHelper);

    // Enhanced model loading
    const loader = new THREE.FBXLoader();
    loader.load(
        '/Blend/Models/Clock.fbx',
        function (object) {
            model = object;
            console.log('Model dimensions:', 
                object.geometry ? object.geometry.boundingBox : 'No geometry');
            
            // Center model
            const box = new THREE.Box3().setFromObject(object);
            const center = box.getCenter(new THREE.Vector3());
            object.position.x += (object.position.x - center.x);
            object.position.y += (object.position.y - center.y);
            object.position.z += (object.position.z - center.z);

            model.scale.set(0.05, 0.05, 0.05);
            scene.add(model);
            
            // Log success with details
            console.log('Model added to scene');
            console.log('Scene children count:', scene.children.length);
            
            // Start with slight tilt
            model.rotation.x = Math.PI * 0.1;
        },
        function (xhr) {
            console.log((xhr.loaded / xhr.total * 100) + '% loaded');
        },
        function (error) {
            console.error('Error loading model:', error);
        }
    );

    window.addEventListener("resize", onWindowResize, false);
    animate();
}

function onWindowResize() {
    camera.aspect = 1;
    camera.updateProjectionMatrix();
    renderer.setSize(600, 600, false);
}

function animate() {
    requestAnimationFrame(animate);
    if (model && isSpinning) {
        model.rotation.y += rotationSpeed;
        
        // Slow down rotation
        rotationSpeed *= 5.99;
        
        // Stop spinning when slow enough
        if (rotationSpeed < 0.001) {
            isSpinning = false;
            // Ensure model is vertical
            model.rotation.y = Math.round(model.rotation.y / (Math.PI * 2)) * (Math.PI * 2);
        }
    }
    renderer.render(scene, camera);
}

init();