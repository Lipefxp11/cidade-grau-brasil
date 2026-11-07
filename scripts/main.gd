extends Node3D

# Protótipo inicial: cenário e moto montados por código para facilitar a edição.
const BIKE_SCRIPT := preload("res://scripts/moto.gd")

var bike: RigidBody3D
var camera: Camera3D
var speed_label: Label

func _ready() -> void:
    _setup_world()
    _setup_bike()
    _setup_camera()
    _setup_hud()

func _setup_world() -> void:
    var world_env := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_SKY
    env.sky = Sky.new()
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color(0.72, 0.78, 0.86)
    env.ambient_light_energy = 0.8
    world_env.environment = env
    add_child(world_env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -30, 0)
    sun.light_energy = 1.25
    add_child(sun)

    _make_box("Chao", Vector3(0, -0.35, 0), Vector3(180, 0.5, 180), Color(0.20, 0.34, 0.22), true)
    _make_box("Asfalto", Vector3(0, -0.08, 0), Vector3(14, 0.12, 180), Color(0.12, 0.13, 0.15), true)
    for z in range(-80, 90, 20):
        _make_box("Faixa", Vector3(0, 0.0, z), Vector3(0.22, 0.025, 7), Color(0.95, 0.88, 0.55), false)

    # Quadra simples com casas coloridas; depois será substituída pelo mapa detalhado.
    var colors = [Color(0.72,0.48,0.32), Color(0.78,0.72,0.58), Color(0.42,0.58,0.66), Color(0.65,0.62,0.48)]
    var index := 0
    for x in [-18.0, 18.0]:
        for z in range(-60, 70, 22):
            var h := 5.0 + float((index % 3) * 1.5)
            _make_box("Casa_%d" % index, Vector3(x, h * 0.5, z), Vector3(10, h, 12), colors[index % colors.size()], true)
            _make_box("Telhado_%d" % index, Vector3(x, h + 0.35, z), Vector3(11, 0.7, 13), Color(0.22,0.20,0.19), false)
            index += 1

func _make_box(n: String, pos: Vector3, size: Vector3, color: Color, collision: bool) -> void:
    var body: StaticBody3D
    if collision:
        body = StaticBody3D.new()
        body.position = pos
        add_child(body)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    if collision:
        body.add_child(mesh)
        var shape := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = size
        shape.shape = box_shape
        body.add_child(shape)
    else:
        mesh.position = pos
        add_child(mesh)

func _setup_bike() -> void:
    bike = RigidBody3D.new()
    bike.name = "Moto_CG160"
    bike.position = Vector3(0, 0.75, 8)
    bike.mass = 190.0
    bike.linear_damp = 0.35
    bike.angular_damp = 2.2
    bike.can_sleep = false
    bike.script = BIKE_SCRIPT
    add_child(bike)
    var bike_collision := CollisionShape3D.new()
    var bike_shape := BoxShape3D.new()
    bike_shape.size = Vector3(0.75, 1.0, 1.8)
    bike_collision.shape = bike_shape
    bike_collision.position = Vector3(0, -0.35, 0)
    bike.add_child(bike_collision)

    _bike_box("Chassi", Vector3(0, 0.35, 0), Vector3(0.28, 0.22, 1.35), Color(0.78, 0.08, 0.06))
    _bike_box("Tanque", Vector3(0, 0.62, -0.08), Vector3(0.48, 0.34, 0.62), Color(0.82, 0.04, 0.03))
    _bike_box("Banco", Vector3(0, 0.78, 0.38), Vector3(0.38, 0.16, 0.62), Color(0.05, 0.05, 0.05))
    _bike_box("Farol", Vector3(0, 0.55, -0.78), Vector3(0.32, 0.28, 0.18), Color(0.9, 0.9, 0.75))
    _bike_wheel(Vector3(0, -0.55, -0.72))
    _bike_wheel(Vector3(0, -0.55, 0.72))

func _bike_box(n: String, pos: Vector3, size: Vector3, color: Color) -> void:
    var mesh := MeshInstance3D.new()
    mesh.name = n
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mesh.material_override = mat
    bike.add_child(mesh)
    mesh.position = pos

func _bike_wheel(pos: Vector3) -> void:
    var mesh := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = 0.34
    cylinder.bottom_radius = 0.34
    cylinder.height = 0.16
    mesh.mesh = cylinder
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.025, 0.025, 0.025)
    mesh.material_override = mat
    bike.add_child(mesh)
    mesh.position = pos
    mesh.rotation_degrees.z = 90

func _setup_camera() -> void:
    camera = Camera3D.new()
    camera.current = true
    camera.position = Vector3(0, 4.2, 7.5)
    add_child(camera)

func _process(delta: float) -> void:
    if is_instance_valid(bike) and is_instance_valid(camera):
        var target := bike.global_position + Vector3(0, 3.1, 7.0)
        camera.global_position = camera.global_position.lerp(target, min(delta * 4.0, 1.0))
        camera.look_at(bike.global_position + Vector3(0, 0.7, -2.0), Vector3.UP)
        if speed_label:
            speed_label.text = "%03d km/h" % int(bike.linear_velocity.length() * 3.6)

func _setup_hud() -> void:
    var layer := CanvasLayer.new()
    add_child(layer)
    var panel := PanelContainer.new()
    panel.position = Vector2(18, 18)
    panel.custom_minimum_size = Vector2(190, 58)
    layer.add_child(panel)
    speed_label = Label.new()
    speed_label.text = "000 km/h"
    speed_label.add_theme_font_size_override("font_size", 24)
    panel.add_child(speed_label)

    _add_touch_button(layer, "◀", Vector2(30, -125), "steer_left")
    _add_touch_button(layer, "▶", Vector2(120, -125), "steer_right")
    _add_touch_button(layer, "FREIO", Vector2(-210, -125), "brake")
    _add_touch_button(layer, "GRAU", Vector2(-110, -225), "wheelie")
    _add_touch_button(layer, "ACELERAR", Vector2(-110, -125), "accelerate")

func _add_touch_button(layer: CanvasLayer, caption: String, offset: Vector2, action: String) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(88, 70)
    button.anchor_left = 1.0 if offset.x < 0 else 0.0
    button.anchor_right = 1.0 if offset.x < 0 else 0.0
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.position = offset
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))
    layer.add_child(button)
