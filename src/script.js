import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import * as dat from 'lil-gui'
import gsap from 'gsap'

import vertexShader from './webgl/shaders/vert.glsl'
import fragmentShader from './webgl/shaders/frag.glsl'

/**
 * Base
 */
// Debug
const gui = new dat.GUI()

// Canvas
const canvas = document.querySelector('canvas.webgl')
const videoDom1 = document.getElementById( 'video1' )
const videoDom2 = document.getElementById( 'video2' )

// Scene
const scene = new THREE.Scene()

/**
 * Textures
 */

const texturePaper = new THREE.TextureLoader().load( '/textures/paper.jpeg' );
const textureVideo1 = new THREE.VideoTexture( videoDom1 )
const textureVideo2 = new THREE.VideoTexture( videoDom2 )
// Size videos
const sizeVideo = {
    x: videoDom1.videoWidth,
    y: videoDom1.videoHeight
}

/**
 * Mouse
 */

let mouse = new THREE.Vector2(0, 0)
window.addEventListener('mousemove', (ev) => { onMouseMove(ev) })
const onMouseMove = (event) => {
    gsap.to(mouse, 1, {
        x: (event.clientX / window.innerWidth) * 2 - 1,
        y: -(event.clientY / window.innerHeight) * 2 + 1
    })
}

/**
 * Test mesh
 */
// Geometry
const geometry = new THREE.PlaneBufferGeometry(1.4, 1.4)

// Material
// const material = new THREE.MeshBasicMaterial({ map: textureVideo1 })
const uniforms = {
    uTex: { type: 't', value: textureVideo1 },
    uTexHover: { type: 't', value: textureVideo2 },
    uTexPaper: { type: 't', value: texturePaper },
    tMap: { value: null },
    uMouse: { value: mouse },
    uTime: { value: 0 },
    uRes: { value: new THREE.Vector2(window.innerWidth, window.innerHeight) }
}

const material =  new THREE.RawShaderMaterial({
    uniforms: uniforms,
    vertexShader: vertexShader,
    fragmentShader: fragmentShader,
    transparent: true,
    wireframe: false,
    side: THREE.DoubleSide,
    defines: {
        PR: window.devicePixelRatio.toFixed(1)
    }
})

// Mesh
const mesh = new THREE.Mesh(geometry, material)
mesh.scale.set(sizeVideo.x / (window.innerHeight - 50), sizeVideo.y / (window.innerHeight - 50), 1)
scene.add(mesh)

/**
 * Sizes
 */
const sizes = {
    width: window.innerWidth,
    height: window.innerHeight
}

window.addEventListener('resize', () =>
{
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    // camera.aspect = sizes.width / sizes.height
    // camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

    // Update Uniforms
    uniforms.uRes.value.x = window.innerWidth
    uniforms.uRes.value.y = window.innerHeight
})

/**
 * Camera
 */
// Base camera
const camera = new THREE.OrthographicCamera( - 1, 1, 1, - 1, 0, 1 );
scene.add(camera)

// Controls
const controls = new OrbitControls(camera, canvas)
controls.enableDamping = true
controls.enabled = false

/**
 * Renderer
 */
const renderer = new THREE.WebGLRenderer({
    canvas: canvas
})
renderer.setSize(sizes.width, sizes.height)
renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))

/**
 * Animate
 */
const clock = new THREE.Clock()

const tick = () =>
{
    const elapsedTime = clock.getElapsedTime()

    // Update shaders
    uniforms.uTime.value += 0.01

    // Update controls
    controls.update()

    // Render
    renderer.render(scene, camera)

    // Call tick again on the next frame
    window.requestAnimationFrame(tick)
}

tick()