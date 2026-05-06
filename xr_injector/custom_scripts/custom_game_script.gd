extends Node

const ClimberState_Attached_mod_script = preload("res://xr_injector/modded_scripts/climber_state_attached_mod.gd")
const ClimberState_Throw_mod_script = preload("res://xr_injector/modded_scripts/climber_state_throw_mod.gd")
const ClimberState_Default_mod_script = preload("res://xr_injector/modded_scripts/climber_state_default_mod.gd")
const ClimberState_Attached_script = preload("res://scripts/climber_state_attached.gd")
const ClimberState_Throw_script = preload("res://scripts/climber_state_throw.gd")
const ClimberState_Default_script = preload("res://scripts/climber_state_default.gd")

@export var hand_wall_slowdown := 0.05

# Convenience XR Scene reference (the parent node of all of UGVR), do not modify, will be set in xr_scene.gd
var xr_scene : Node3D = null
# Convenience reference to the node at the top of the scene tree in any game, allows finding or getting other nodes in game scene tree
var scene_root = null
# Track whether single use function has already been called
var on_xr_setup_already_run : bool = false
# track problematic scene changes
var stop_process_flag = false
var prev_scene : Node = null

# main reference for changing player logic
var climber : Node = null

var climber_head_collision : Node = null
var mod_camera_parent : Node3D = null

#flag for initializing mod because we need to wait for the xr_Scene to settle
var setup_request = true
var is_setup = false



func _ready():
	
	pass
	
func _on_scene_changed(new_scene: Node) -> void:
	if new_scene:
		print("scene changed to: ", new_scene.scene_file_path)
		var path := new_scene.scene_file_path
		if new_scene.scene_file_path == "res://scenes/you_died_scene.tscn":
			new_scene.time_in_scene = 10.0
			stop_process_flag = true
			xr_scene.set_process(false)
			return
		else:
			stop_process_flag = false
			xr_scene.set_process(true)
			
		if path == "res://scenes/MainMenu.tscn":
			var menu := get_tree().get_root().get_node_or_null("Node3D2/MainMenuUI/MainContainer/DefaultTab/MainList/Settings")
			if menu != null:
				menu.get_parent().remove_child(menu)
				menu.queue_free()
				return

		setup_request = true
		is_setup = false
	else:
		print("scene changed to null")

func _process(delta):
	var scene := get_tree().current_scene
	if scene != prev_scene:
		prev_scene = scene
		_on_scene_changed(scene)
	if stop_process_flag:
		return
	# Don't try to run code if xr_scene not set yet
	if stop_process_flag or not xr_scene:
		return
	
	if setup_request and Engine.get_process_frames() % 90 == 0:
		setup_mod()
		
	# Mod player state to enable analogue joystick values.
	if is_setup:
		var s = climber.activeClimberState.get_script()
		if s == ClimberState_Attached_script: 
			replace_state(climber, climber.activeClimberState, ClimberState_Attached_mod_script)
		elif s == ClimberState_Throw_script:
			replace_state(climber, climber.activeClimberState, ClimberState_Throw_mod_script)
		#elif s is ClimberState_Default and not (s is ClimberState_Default_mod):
		#	replace_state(climber, s, ClimberState_Default_mod)
		
		if xr_scene.use_palm_healthbar:	
			if xr_scene.get_parent().get_parent() is CharacterBody3D:
				update_palm_hud_fade()
	
var head_collider_offset := Vector3(0.0, 0.07, 0.0)
func _physics_process(delta):
	# Don't try to run code if xr_scene not set yet
	if not xr_scene:
		return
		
	if climber_head_collision != null and is_instance_valid(climber_head_collision):
		climber_head_collision.global_position = xr_scene.xr_camera_3d.global_position + head_collider_offset * xr_scene.xr_world_scale


var primary_hook_down := false
var secondary_hook_down := false

func _input(event: InputEvent) -> void:
	if Dialogic.current_timeline != null:
		return
		
	var toggle_mode = GameSettings.config.get_value("input", "hook_toggle_mode", false)

	if event.is_action_pressed("ioa_hook_primary"):
		primary_hook_down = true
		on_hook_pressed(toggle_mode, true)

	elif event.is_action_pressed("ioa_hook_secondary"):
		secondary_hook_down = true
		on_hook_pressed(toggle_mode, false)

	if event.is_action_released("ioa_hook_primary"):
		primary_hook_down = false
		on_hook_released(toggle_mode)

	elif event.is_action_released("ioa_hook_secondary"):
		secondary_hook_down = false
		on_hook_released(toggle_mode)
		
func on_hook_pressed(toggle_mode: bool, isPrimary : bool) -> void:
	if not climber.grapple_claw_is_enabled:
		return

	if not toggle_mode:

		#thrower_node
		var t = ClimberState_Throw_mod_script.new()
		t._movement_device = mod_camera_parent

		if isPrimary:
			climber.Rope._claw.thrower_node = xr_scene.xr_right_controller
			climber.Edge.set_root(xr_scene.xr_right_hand, xr_scene.use_physics_hands)
		else:
			climber.Rope._claw.thrower_node = xr_scene.xr_left_controller
			climber.Edge.set_root(xr_scene.xr_left_hand, xr_scene.use_physics_hands)
			
		climber.set_climber_state(t)
	else:
		if climber.activeClimberState != climber.defaultClimberState:
			climber.set_climber_state(climber.defaultClimberState)
			
		elif not (climber.activeClimberState is ClimberState_Throw):
			var t = ClimberState_Throw_mod_script.new()
			t._movement_device = mod_camera_parent
			
			if isPrimary:
				climber.Rope._claw.thrower_node = xr_scene.xr_right_controller
				climber.Edge.set_root(xr_scene.xr_right_hand, xr_scene.use_physics_hands)
			else:
				climber.Rope._claw.thrower_node = xr_scene.xr_left_controller
				climber.Edge.set_root(xr_scene.xr_left_hand, xr_scene.use_physics_hands)
				
			climber.set_climber_state(t)

func on_hook_released(toggle_mode: bool) -> void:
	if toggle_mode:
		return

	if primary_hook_down or secondary_hook_down:
		return

	climber.set_climber_state(climber.defaultClimberState)

func setup_mod():
	print("mod setup")
	
	climber = find_first_node_by_name("Climber")
	if climber == null or xr_scene.xr_camera_3d == null or !is_instance_valid(xr_scene.xr_camera_3d):
		print("mod setup fail")
		return
	setup_request = false
	
	modify_ui_style()
	
	primary_hook_down = false
	secondary_hook_down = false
	
	match xr_scene.movement_direction_device:
		1:
			mod_camera_parent = xr_scene.primary_controller
		2: 
			mod_camera_parent = xr_scene.secondary_controller
		_:
			mod_camera_parent = xr_scene.xr_camera_3d
	
	var new_default_state = ClimberState_Default_mod_script.new()
	new_default_state.copy_state(climber.defaultClimberState)
	new_default_state._movement_device = mod_camera_parent
	new_default_state.ignore_sprint = xr_scene.ignore_sprint
	
	climber.defaultClimberState = new_default_state
	climber.activeClimberState = new_default_state
	
	if xr_scene.use_palm_healthbar:
		#check for existing UI
		for child in xr_scene.xr_left_hand.get_children():
			if child is SubViewport or child is MeshInstance3D:
				child.queue_free()
				
		var ui_parent = xr_scene.xr_left_hand.get_node("HandMesh")
		if ui_parent == null:
			ui_parent = xr_scene.xr_left_hand.get_node("Hand_Nails_low_L")
		create_subviewport(ui_parent)
		
		steal_healthbar()
	
	if xr_scene.use_physics_hands:
		xr_scene.xr_right_hand.blocked.connect(on_hand_blocked)
		xr_scene.xr_right_hand.unblocked.connect(on_hand_unblocked)
		xr_scene.xr_left_hand.blocked.connect(on_hand_blocked)
		xr_scene.xr_left_hand.unblocked.connect(on_hand_unblocked)
		
	# get head collider transform or make one
	if xr_scene.use_head_collider:
		if climber_head_collision == null or !is_instance_valid(climber_head_collision):
			for child in climber.get_children():
				if child is CollisionShape3D:
					if child.shape is SphereShape3D:
						climber_head_collision = child
						climber_head_collision.shape.radius = 0.25 * xr_scene.xr_world_scale
			if climber_head_collision == null:
				climber_head_collision = CollisionShape3D.new()
				var sphere := SphereShape3D.new()
				sphere.radius = 0.25 * xr_scene.xr_world_scale
				climber_head_collision.shape = sphere
				climber.add_child(climber_head_collision)
				
				
	# Script overrides
	var playercameramod := load("res://xr_injector/modded_scripts/player_camera_mod.gd")
	climber.PlayerCamera.set_script(playercameramod)
	
	var edgemod := load("res://xr_injector/modded_scripts/climbing_edge_player_mod.gd")
	climber.Edge.set_script(edgemod)
	climber.Edge.setup(climber)
	climber.Edge.set_root(xr_scene.xr_right_hand, xr_scene.use_physics_hands)
	climber.Edge.scale = xr_scene.xr_world_scale * 0.85
	var light := climber.get_node_or_null("OmniLight3D") as OmniLight3D
	if light != null:
		light.light_energy *= xr_scene.player_light_multiplier

	var clawmod := load("res://xr_injector/modded_scripts/climber_claw_mod.gd")
	var _claw = climber.Rope._claw

	var _edge =  _claw._edge
	var _visualHook = _claw._visualHook
	var _meshInstanceHook=_claw._meshInstanceHook
	var _collisionShape = _claw._collisionShape
	var omni_light = _claw.omni_light
	
	_claw.set_script(clawmod)
	_claw._visualHook = _visualHook
	_claw._meshInstanceHook = _meshInstanceHook
	_claw._collisionShape = _collisionShape
	_claw.omni_light = omni_light
	_claw._climber = climber
	_claw._edge = _edge
	#TODO: change on keypress
	_claw.thrower_node=xr_scene.xr_right_hand
	_claw.default_light_intensity *= xr_scene.player_light_multiplier
	_claw.omni_light.light_energy *= xr_scene.player_light_multiplier
	_claw._ready()

	var ropevisualmod := load("res://xr_injector/modded_scripts/climber_rope_visual_mod.gd")
	var ropevisual = climber.Rope._rope_visual
	ropevisual.set_script(ropevisualmod)
	ropevisual.scale_radius = xr_scene.xr_world_scale * 0.85
	ropevisual.setup(climber.Rope)
	
	# set hands material to normal depth test
	var left = xr_scene.xr_left_hand.get_node_or_null("HandMesh/Armature/Skeleton3D/mesh_Hand_Nails_low_L")
	if left == null:
		left = xr_scene.xr_left_hand.get_node_or_null("Hand_Nails_low_L/Armature/Skeleton3D/mesh_Hand_Nails_low_L")
	var right = xr_scene.xr_right_hand.get_node_or_null("HandMesh/Armature/Skeleton3D/mesh_Hand_Nails_low_R")
	if right == null:
		right = xr_scene.xr_right_hand.get_node_or_null("Hand_Nails_low_R/Armature/Skeleton3D/mesh_Hand_Nails_low_R")
	
	left.get_active_material(0).no_depth_test = false
	
	
	
	is_setup = true
	
func on_hand_blocked():
	climber.Rope._settings.airVelocityDrag += xr_scene.physics_hand_drag
	pass
	
func on_hand_unblocked():
	climber.Rope._settings.airVelocityDrag -= xr_scene.physics_hand_drag
	if climber.Rope._settings.airVelocityDrag < 0.001:
		climber.Rope._settings.airVelocityDrag = 0.001
	pass
	
func modify_ui_style():
	var healthbar = climber.get_node("Hud/HealthbarRoot/Health")
	if healthbar != null:
		var style := healthbar.get_theme_stylebox("background").duplicate() as StyleBoxTexture
		style.modulate_color = Color.BLACK
		healthbar.add_theme_stylebox_override("background", style)
	var slack = climber.get_node("Hud/SlackCircle")
	if slack != null:
		slack.material.set_shader_parameter("un_fill_color", Color.BLACK)
	
var mod_viewport : SubViewport
var mod_viewport_control : Control
var viewportscale = 0.7
func create_subviewport(parent_3d: Node3D) -> void:
	mod_viewport = SubViewport.new()
	mod_viewport.size = Vector2i(128, 128)
	mod_viewport.transparent_bg = true
	mod_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	mod_viewport_control = Control.new()
	mod_viewport_control.size = Vector2(128, 128)

	mod_viewport.add_child(mod_viewport_control)

	var mesh := MeshInstance3D.new()
	mesh.mesh = QuadMesh.new()
	mesh.mesh.size = Vector2(0.1, 0.1)
	mesh.scale = Vector3(viewportscale,viewportscale,viewportscale)
	mesh.name = "floatingbar"
	

	var mat := StandardMaterial3D.new()
	mat.albedo_texture = mod_viewport.get_texture()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	mesh.material_override = mat
	mesh.position = Vector3(0.033, -0.003, -0.045) * xr_scene.xr_world_scale
	mesh.rotation_degrees = Vector3(0, 90, -90)

	parent_3d.add_child(mod_viewport)
	parent_3d.add_child(mesh)

func steal_healthbar() -> void:
	var hud = climber.get_node_or_null("Hud")

	if hud == null or mod_viewport_control == null:
		return

	var hbar = hud.get_node_or_null("HealthbarRoot")
	if hbar == null:
		return
		
	var slack := hud.get_node_or_null("SlackCircle") as TextureRect
	if slack == null:
		return

	hud.remove_child(hbar)
	mod_viewport_control.add_child(hbar)
	hbar.anchor_left = 0.5
	hbar.anchor_right = 0.5
	hbar.anchor_top = 0.5
	hbar.anchor_bottom = 0.5

	hbar.offset_left = -61
	hbar.offset_top = -5
	hbar.offset_right = 61
	hbar.offset_bottom = 5
	
	
	hud.remove_child(slack)
	mod_viewport_control.add_child(slack)
	slack.anchor_left = 0.5
	slack.anchor_right = 0.5
	slack.anchor_top = 0.678
	slack.anchor_bottom = 0.678

	slack.offset_left = -19
	slack.offset_top = -19
	slack.offset_right = 20
	slack.offset_bottom = 20

func update_palm_hud_fade() -> void:
	for child in xr_scene.xr_left_hand.get_children():
		if child is MeshInstance3D:            
			var to_camera = (xr_scene.xr_camera_3d.global_position - xr_scene.xr_left_hand.global_position).normalized()

			var palm_normal = xr_scene.xr_left_hand.global_basis.x.normalized()

			var facing = palm_normal.dot(to_camera)
			var target_alpha = clamp(inverse_lerp(0.6, 0.9, facing), 0.0, 1.0)

			var mat := child.material_override as StandardMaterial3D
			if mat == null:
				return
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = target_alpha
			return

func replace_state(climber: Climber, old_state, mod_type: GDScript) -> void:
	var new_state = mod_type.new()
	new_state.copy_state(old_state)
	new_state._movement_device = mod_camera_parent
	new_state.ignore_sprint = xr_scene.ignore_sprint
	climber.activeClimberState = new_state


## Built in UGVR Convenience Functions for Your Potential Use
# But remember you have full access to all Godot GDSCript scripting for Godot 4 - just be mindful of game's Godot version.
# To be on the safe side, aim to use Godot 4.2 documentation when finding potential methods, properties and signals

# Convenience function to get node reference by absolute path to node
func get_node_reference_by_absolute_path(absolute_node_path : NodePath) -> Node:
	var node = get_node_or_null(absolute_node_path)
	return node

# Convenience function to get node from path relative to scene root 
func get_node_from_scene_root_relative_path(relative_path_from_scene_root : String) -> Node:
	if not scene_root:
		return null
	var node = scene_root.get_node_or_null(relative_path_from_scene_root)
	return node

# Convenience function to find the first game node with a certain name in the scene
# Use * to match any number of wildcard characters and ? to match any single wildcard character
func find_first_node_by_name(node_name_pattern : String) -> Node:
	if not scene_root:
		return null
	var found_node : Node = scene_root.find_child(node_name_pattern, true, false)
	return found_node

# Convenience function to find all game nodes with a name containing the pattern string in the scene
# Use * to match any number of wildcard characters and ? to match any single wildcard character
func find_all_nodes_with_pattern_in_name(pattern_in_name : String) -> Array:
	if not scene_root:
		return []
	var found_nodes : Array = scene_root.find_children(pattern_in_name, "", true, false)
	return found_nodes

# Convenience function to find all game nodes of a certain class in the scene
func find_nodes_by_class(class_type : String) -> Array:
	if not scene_root:
		return []
	var class_nodes : Array = scene_root.find_children("*", class_type, true, false)
	return class_nodes

# Convenience function to move game node to track controller, may not work in all instances, offset is x, y, z relative to controller
func reparent_game_node_to_controller(game_node : Node3D, controller : XRController3D, offset: Vector3 = Vector3(0,0,0)) -> void:
	var remote_transform : RemoteTransform3D = RemoteTransform3D.new()
	var node_holder : Node3D = Node3D.new()
	controller.add_child(node_holder)
	node_holder.transform.origin = offset
	node_holder.add_child(remote_transform)
	remote_transform.update_scale = false
	remote_transform.remote_path = game_node.get_path()

# Convenience function to move game node to track HMD, may not work in all instances, offset is x, y, z relative to HMD
func reparent_game_node_to_hmd(game_node : Node3D, hmd_node : XRCamera3D, offset: Vector3 = Vector3(0,0,0)) -> void:
	var remote_transform : RemoteTransform3D = RemoteTransform3D.new()
	var node_holder : Node3D = Node3D.new()
	hmd_node.add_child(node_holder)
	node_holder.transform.origin = offset
	node_holder.add_child(remote_transform)
	remote_transform.update_scale = false
	remote_transform.remote_path = game_node.get_path()

# Convenience function to hide a node.  May need to be run in _process if other game code may dynamically hide and show the element
func hide_node(node : Node) -> void:
	if node.has_method("hide"):
		node.hide()
	else:
		for property_dictionary in node.get_property_list():
			if "visible" in property_dictionary["name"]:
				node.visible = false
				break

# Convenience function to show a hidden node. May need to be run in _process if other game code may dynamically hide and show the element
func show_node(node : Node) -> void:
	if node.has_method("show"):
		node.show()
	else:
		for property_dictionary in node.get_property_list():
			if "visible" in property_dictionary["name"]:
				node.visible = true
				break

# Setter function for xr_scene reference, called in xr_scene.gd automatically
func set_xr_scene(new_xr_scene) -> void:
	xr_scene = new_xr_scene
	scene_root = get_node("/root")
	xr_scene.xr_pointer.set_enabled(false)
	InputMap.action_erase_events("ioa_hook")
