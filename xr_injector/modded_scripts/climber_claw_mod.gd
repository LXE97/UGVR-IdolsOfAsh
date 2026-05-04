extends ClimberClaw

var thrower_node : Node = null

func throw_claw(amt: float):
	var from_pos = thrower_node.get_global_position()
	var claw_impulse: Vector3 = thrower_node.global_basis.z * -13.0
	apply_central_impulse(claw_impulse * amt)
	Game.audio.play_sfx_hook_thrown()
	
func on_throw_begin(climber: Climber):
	freeze = false
	visible = true

	climber.Rope.reset_edges()
	
	var new_claw_position: Vector3 = thrower_node.global_position
	var new_claw_rotation: Vector3 = thrower_node.global_basis.get_euler() + Vector3(PI, 0.0, 0.0)
	var new_claw_transform: Transform3D = Transform3D(Basis.from_euler(new_claw_rotation), new_claw_position)

	PhysicsServer3D.body_set_state(
		get_rid(), 
		PhysicsServer3D.BODY_STATE_TRANSFORM, 
		new_claw_transform
	)
	PhysicsServer3D.body_set_state(
		get_rid(), 
		PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, 
		_climber.velocity
	)
	PhysicsServer3D.body_set_state(
		get_rid(), 
		PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, 
		Vector3.ZERO
	)
	global_position = new_claw_transform.origin
	global_rotation = new_claw_transform.basis.get_euler()

	reset_physics_interpolation()
	_edge.reset_physics()

	throw_claw(1.0)
