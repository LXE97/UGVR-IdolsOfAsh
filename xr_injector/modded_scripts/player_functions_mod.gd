extends Node

const inputAction_Forward: = "ioa_fp_movement_forward"
const inputAction_Backward: = "ioa_fp_movement_back"
const inputAction_Left: = "ioa_fp_movement_left"
const inputAction_Right: = "ioa_fp_movement_right"

static func GetGlobalMovementVector(device: Node3D) -> Vector3:
	if !is_instance_valid(device):
		return Vector3.ZERO

	var input := Vector2(
		Input.get_axis(inputAction_Left, inputAction_Right),
		Input.get_axis(inputAction_Forward, inputAction_Backward)
	)

	if input.length_squared() <= 0.01:
		return Vector3.ZERO

	var forward := device.global_transform.basis.z
	forward.y = 0.0

	if forward.length_squared() <= 0.0001:
		return Vector3.ZERO

	forward = forward.normalized()

	var right := Vector3.UP.cross(forward).normalized()

	var movement_vector := forward * input.y + right * input.x
	return movement_vector.limit_length(1.0)

static func CurveInput(min, max, input, deadzone) -> float:
	if input <= deadzone:
		return min

	#cubic scaling
	#input = input*input*input
	input = remap(input, deadzone, 1.0, min, max)
	input = clamp(input, min, max)

	return input
	
