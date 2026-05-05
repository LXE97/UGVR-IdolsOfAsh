extends ClimberState_Throw

var _movement_device : Node

var ignore_sprint = true
var deadzone = 0.05

func copy_state(target : ClimberState_Throw):
	_climber=target._climber
	_time_in_state=target._time_in_state
	_slack = target._slack
	_player_has_slack_control = target._player_has_slack_control

func _physics_process(delta: float, input_vector: Vector3):
	var inputGlobalMovementVector = GetGlobalMovementVector(_movement_device)
	
	var max_speed = _climber.WalkSpeed * _climber.WalkSpeedMultiplier
	if ignore_sprint:
		max_speed *= 2.0
	
	# scale with curve
	inputGlobalMovementVector *= CurveInput(0.0, max_speed, inputGlobalMovementVector.length(), deadzone)
	
	# sprinting controls
	if !ignore_sprint:
		var should_sprint: bool = Input.is_action_pressed("ioa_sprint")
		if GameSettings.config.get_value("input", "sprint_by_default", false):
			should_sprint = not should_sprint
		if _climber.is_on_floor() and _climber.sprint_is_enabled and should_sprint:
			inputGlobalMovementVector *= 2.0
		
		
	super(delta, inputGlobalMovementVector)
func GetGlobalMovementVector(device: Node3D) -> Vector3:
	if !is_instance_valid(device):
		return Vector3.ZERO

	var input := Vector2(
		Input.get_axis(PlayerFunctions.inputAction_Left, PlayerFunctions.inputAction_Right),
		Input.get_axis(PlayerFunctions.inputAction_Forward, PlayerFunctions.inputAction_Backward)
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
	
func CurveInput(min, max, input, deadzone) -> float:
	if input <= deadzone:
		return min

	#cubic scaling
	#input = input*input*input
	input = remap(input, deadzone, 1.0, min, max)
	input = clamp(input, min, max)

	return input
