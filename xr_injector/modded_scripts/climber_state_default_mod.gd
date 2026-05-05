class_name ClimberState_Default_mod extends ClimberState_Default

var _movement_device : Node

func copy_state(target : ClimberState_Default):
	_climber=target._climber
	_time_in_state=target._time_in_state

func _physics_process(delta: float, input_vector: Vector3):
	var inputGlobalMovementVector = PlayerFunctions_mod.GetGlobalMovementVector(_movement_device) * _climber.WalkSpeed * _climber.WalkSpeedMultiplier
	
	var should_sprint: bool = Input.is_action_pressed("ioa_sprint")
	if GameSettings.config.get_value("input", "sprint_by_default", false):
		should_sprint = not should_sprint

	if _climber.is_on_floor() and _climber.sprint_is_enabled and should_sprint:
		inputGlobalMovementVector *= 2.0
		
	super(delta, inputGlobalMovementVector)
