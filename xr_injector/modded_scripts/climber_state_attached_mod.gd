class_name ClimberState_Attached_mod extends ClimberState_Attached

var _movement_device : Node

func copy_state(target : ClimberState_Attached):
	_climber=target._climber
	_time_in_state=target._time_in_state
	_slack = target._slack
	_extra_slack = target._extra_slack
	_last_ledge_climb_velocity_bump_ms=target._last_ledge_climb_velocity_bump_ms
	_ledge_climb_strength_buffer=target._ledge_climb_strength_buffer
	_raycast_params=target._raycast_params

func _physics_process(delta: float, input_vector: Vector3):
	var inputGlobalMovementVector = PlayerFunctions_mod.GetGlobalMovementVector(_movement_device) * _climber.WalkSpeed * _climber.WalkSpeedMultiplier
	
	var should_sprint: bool = Input.is_action_pressed("ioa_sprint")
	if GameSettings.config.get_value("input", "sprint_by_default", false):
		should_sprint = not should_sprint

	if _climber.is_on_floor() and _climber.sprint_is_enabled and should_sprint:
		inputGlobalMovementVector *= 2.0
		
	super(delta, inputGlobalMovementVector)
