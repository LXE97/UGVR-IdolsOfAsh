extends ClimbingEdgePlayer

var hand : Node = null
var root_node : Node = null

const offset = Vector3(0.0, -0.055, 0.117)
var scale = 1.0

func get_global_position() -> Vector3:
	if root_node != null:
		return root_node.global_transform * Transform3D(Basis.IDENTITY, offset * scale).origin
	else:
		return Vector3.ZERO

func set_root(target: Node, use_physics: bool):
	if use_physics:
		hand = target
		root_node = hand.get_parent()
		hand.blocked.connect(_on_hand_blocked)
		hand.unblocked.connect(_on_hand_unblocked)
	else:
		root_node = target

func _on_hand_blocked() -> void:
	print("Hand blocked")
	root_node = hand

func _on_hand_unblocked() -> void:
	print("Hand unblocked")
	root_node = hand.get_parent()

func apply_correction(climber: Climber, delta: float):

	var grapplePointActive: ClimbingEdge = _climber.Rope._climbing_edges[1]
	if not grapplePointActive:
		return

	var grapplePointPosition: = grapplePointActive.get_global_position();

	var currentSwingRopeLength: float = _climber.Rope.get_swing_length_from_edge(grapplePointActive)
	var currentRopeSlackLength: float = _climber.activeClimberState.get_slack_length()
	currentSwingRopeLength -= currentRopeSlackLength
	currentSwingRopeLength = clampf(currentSwingRopeLength, 0.0, _climber.Rope._settings.ropeLengthMax)

	var playerToGrapplePoint: Vector3 = (grapplePointPosition - climber.global_position)
	var restPoint: Vector3 = grapplePointPosition + Vector3.DOWN * currentSwingRopeLength
	var playerToRestPoint: Vector3 = (restPoint - climber.global_position)
	var swingAngle: float = playerToGrapplePoint.angle_to(Vector3.UP)
	var velocityRight: Vector3 = playerToRestPoint.normalized().cross(playerToGrapplePoint.normalized())
	var perpendicularVectorOnSwingCircle: Vector3 = playerToGrapplePoint.normalized().cross(velocityRight)

	var projectedDistanceToGrapplePoint: float = climber.global_position.distance_to(grapplePointPosition);

	var distPastRopeLength_NextFrame: float = projectedDistanceToGrapplePoint - currentSwingRopeLength
	distPastRopeLength_NextFrame = clampf(distPastRopeLength_NextFrame, -0.5, 0.5)

	if !climber.is_on_floor():

		if playerToGrapplePoint.dot(Vector3.UP) > 0.0:
			climber.AirVelocity += _climber.Rope._settings.swingSpeed * perpendicularVectorOnSwingCircle * currentSwingRopeLength * sin(swingAngle)
	else:
		var total_rope_length: = _climber.Rope.get_total_length_between_edges()
		if total_rope_length < _climber.Rope._settings.ropeLengthMax:
			var slack_that_can_be_consumed_automatically = clamp(distPastRopeLength_NextFrame, 0.0, _climber.Rope._settings.ropeLengthMax - total_rope_length)
			_climber.activeClimberState.request_additional_slack( - slack_that_can_be_consumed_automatically)
			distPastRopeLength_NextFrame -= slack_that_can_be_consumed_automatically * 1.01

	if distPastRopeLength_NextFrame > 0.0:

		if distPastRopeLength_NextFrame > 0.25:
			climber.activeClimberState.request_additional_slack(-40.0 * (distPastRopeLength_NextFrame * distPastRopeLength_NextFrame))

		var swing_point: Vector3 = grapplePointPosition - playerToGrapplePoint.normalized() * currentSwingRopeLength

		if (climber.AirVelocity.length() > 0.01):
			var to_swing_point: Vector3 = climber.global_position.direction_to(swing_point)
			var corrected_air_velocity_amt: float = clamp(climber.AirVelocity.dot( - to_swing_point), 0.0, 999.9)

			if climber.was_recently_sliding_down_rope():
				corrected_air_velocity_amt = clamp(corrected_air_velocity_amt - 10.0, 0.0, 999.0)
			else:
				corrected_air_velocity_amt = clamp(corrected_air_velocity_amt - 0.1, 0.0, 999.0)

			var velocity_to_subtract: Vector3 = to_swing_point * corrected_air_velocity_amt
			climber.AirVelocity += velocity_to_subtract * 0.99

			var velocity_change_magnitude: float = velocity_to_subtract.length()
			if (velocity_change_magnitude >= _climber.Rope._settings.ropeDistanceCorrectionFactor * 0.5):
				Game.audio.play_sfx_rop_max_tension()

			var dmg_from_over_tension: float = velocity_change_magnitude * 0.66
			dmg_from_over_tension -= 8.0
			dmg_from_over_tension *= math_helpers.clamp01(climber.AirVelocity.length() * 0.02)
			if dmg_from_over_tension > 10.0:
				if Time.get_ticks_msec() > climber.last_damage_from_over_tension_ms + 1000:
					climber.last_damage_from_ovstateer_tension_ms = Time.get_ticks_msec()
					climber.take_damage(dmg_from_over_tension)
		
		# Fix for phasing through ledges
		var delta_move = swing_point - climber.global_position
		var max_step = 0.05
		if delta_move.length() > currentSwingRopeLength * max_step:		
			delta_move = delta_move.normalized() * currentSwingRopeLength * max_step

		var collision := climber.move_and_collide(delta_move)

		if collision:
			var remainder := collision.get_remainder()
			var normal := collision.get_normal()

			var slide := remainder.slide(normal)
			climber.move_and_collide(slide)
		
		climber.AirVelocity *= pow(0.999, delta * 60.0)
		
		# this causes oscillation when near the top of a wall and the player hand is above the wall
		#climber.global_position = lerp(climber.global_position, swing_point, math_helpers.clamp01(time_since_ledge_climb) * clamp(playerToGrapplePoint.y, 0.1, 1.0))
	elif _climber.Rope._settings.shouldRemoveSlackImmediately:

		_climber.activeClimberState.request_additional_slack( - distPastRopeLength_NextFrame)



	if !climber.is_on_floor():
		climber.AirVelocity *= (1.0 - _climber.Rope._settings.airVelocityDrag)

	climber.velocity = climber.AirVelocity
	time_since_ledge_climb += delta
