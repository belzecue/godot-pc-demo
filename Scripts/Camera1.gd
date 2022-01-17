extends Camera

export(bool) var mouse_x_invert : bool = false
export(bool) var mouse_y_invert : bool = false
export(bool) var mouse_scaling : bool = false
export(float, 0, 1, 0.05) var look_speed : float = 0.2
export(float, 1, 5, 0.5) var move_speed : float = 1.0
export(float, 1, 10, 0.5) var move_speed_mult : float = 4.0
export(String) var __move_speed_hint : String = "Speed boost (shift)"
export(float, 0, 20, 0.1) var move_inertia : float = 10.0

var velocity : Vector3
var momentum : Vector3
var rot : Array = [0, 0]
var mouse_scaling_ratio : float

onready var bool_mouse_x_invert : int = mouse_x_invert as int * 2 - 1
onready var bool_mouse_y_invert : int = mouse_y_invert as int * 2 - 1

# Map keyboard to actions.
enum key_map {
	LEFT = KEY_A,
	RIGHT = KEY_D,
	FORWARD = KEY_W,
	BACK = KEY_S,
}


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var screen : Vector2 = get_viewport().size
	mouse_scaling_ratio = screen.x / screen.y


func _input(event) -> void:

	# Handle mouse.
	if event is InputEventMouseMotion:
		rot = [rot[0] + event.relative.x, rot[1] + event.relative.y]
		transform.basis = Quat().xform(
			Vector3(
				rot[1] * bool_mouse_x_invert,
				rot[0] * bool_mouse_y_invert * (mouse_scaling_ratio if mouse_scaling else 1.0),
				0
			) * get_process_delta_time() * look_speed
		)
	
	# Handle movement.
	elif event is InputEventKey:
		velocity = Vector3.ZERO
		if Input.is_key_pressed(key_map.LEFT):
			velocity += Vector3.LEFT
		if Input.is_key_pressed(key_map.RIGHT):
			velocity += Vector3.RIGHT
		if Input.is_key_pressed(key_map.FORWARD):
			velocity += Vector3.FORWARD
		if Input.is_key_pressed(key_map.BACK):
			velocity += Vector3.BACK
			
		velocity = (velocity.normalized() * move_speed) * (move_speed_mult if Input.is_key_pressed(KEY_SHIFT) else 1.0)


func _process(delta) -> void:
	# Apply movement.
	if velocity != Vector3.ZERO:
		momentum = velocity
		translate(velocity * delta)
	elif momentum.length_squared() > 0.001:
		momentum = momentum.linear_interpolate(Vector3.ZERO, delta * move_inertia)
		translate(momentum * delta)
