extends Node

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

		setup_mod()
	else:
		print("scene changed to null")

# Called only once after xr scene and all convenience variables are set, insert any code you want to run then here
# Note that you can now access any of the xr scene variables directly at this point, example: xr_scene.xr_pointer.enabled=false
func _on_xr_setup_run_once():
	xr_scene.xr_pointer.set_enabled(false)

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
	
	# Run single use function the first time after all convenience variables are set up
	if not on_xr_setup_already_run:
		on_xr_setup_already_run = true
		_on_xr_setup_run_once()
	
	# Note that you can now access any of the xr scene variables directly, example: xr_scene.xr_pointer.enabled=false

func _physics_process(delta):
	# Don't try to run code if xr_scene not set yet
	if not xr_scene:
		return

func setup_mod():
	print("mod setup")
	
	climber = find_first_node_by_name("Climber")
	if climber == null:
		print("mod setup fail")
		return
		
	# Script overrides
	var playercameramod := load("res://xr_injector/modded_scripts/player_camera_mod.gd")
	climber.PlayerCamera.set_script(playercameramod)
	
	var edgemod := load("res://xr_injector/modded_scripts/climbing_edge_player_mod.gd")
	climber.Edge.set_script(edgemod)
	climber.Edge.setup(climber)
	climber.Edge.set_root(xr_scene.xr_right_hand)

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

	var ropevisualmod := load("res://xr_injector/modded_scripts/climber_rope_visual_mod.gd")
	var ropevisual = climber.Rope._rope_visual
	ropevisual.set_script(ropevisualmod)
	ropevisual.scale_radius = xr_scene.xr_world_scale
	ropevisual.setup(climber.Rope)
	
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
