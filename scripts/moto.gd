extends RigidBody3D

@export var acceleration_force: float = 1250.0
@export var brake_force: float = 18.0
@export var steering_torque: float = 95.0
@export var wheelie_torque: float = 145.0
@export var max_speed: float = 34.0

func _physics_process(_delta: float) -> void:
    var forward := -global_transform.basis.z
    var speed := linear_velocity.length()

    if Input.is_action_pressed("accelerate") and speed < max_speed:
        apply_central_force(forward * acceleration_force)

    if Input.is_action_pressed("brake"):
        linear_velocity = linear_velocity.move_toward(Vector3.ZERO, brake_force * get_physics_process_delta_time())

    var steer := Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
    if abs(steer) > 0.01:
        apply_torque(Vector3.UP * steer * steering_torque * clamp(speed / 5.0, 0.25, 1.0))

    if Input.is_action_pressed("wheelie") and speed > 3.0:
        apply_torque(global_transform.basis.x * wheelie_torque)

    # Estabilização leve para o protótipo; não substitui suspensão/rodas físicas.
    var local_up := global_transform.basis.y
    var correction := local_up.cross(Vector3.UP)
    apply_torque(correction * 32.0)
