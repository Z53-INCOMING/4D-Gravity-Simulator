extends Node3D

@export var world_pos = Vector4.ZERO

@export var radius = 0.5 # warning, not used by sim, just visual

@export var mass = 1.0 # warning, not currently used by gravity sim

@onready var main_sphere = $Main

@onready var kata_slice = $KataSlice

@onready var ana_slice = $AnaSlice

var past_position = Vector4.ZERO

var acceleration = Vector4.ZERO

var id = 0

var xw_angle = 0.0

var zw_angle = 0.0

func _ready():
	kata_slice.radius = radius - 0.01
	ana_slice.radius = radius - 0.01
	Globals.physics_objects.append(self)
	id = Globals.physics_objects.size() - 1

func _process(delta):
	# rotation update
	if Globals.xw_angle != xw_angle:
		# calculate angle change and get things ready for the math
		var angle_change = Globals.xw_angle - xw_angle
		xw_angle = Globals.xw_angle
		var camera = get_parent().get_child(0)
		world_pos.x -= camera.global_position.x
		world_pos.w -= Globals.camera_w
		
		# rotate the particle
		var new_x = (world_pos.x * cos(angle_change)) - (world_pos.w * sin(angle_change))
		var new_w = (world_pos.x * sin(angle_change)) + (world_pos.w * cos(angle_change))
		
		# move the point back to original location (now rotated)
		world_pos.x = new_x + camera.global_position.x
		world_pos.w = new_w + Globals.camera_w
		
		# move past_position so that camera is at the origin
		past_position.x -= camera.global_position.x
		past_position.w -= Globals.camera_w
		
		# rotate past position
		var new_x_2 = (past_position.x * cos(angle_change)) - (past_position.w * sin(angle_change))
		var new_w_2 = (past_position.x * sin(angle_change)) + (past_position.w * cos(angle_change))
		
		# move past position back to original location
		past_position.x = new_x_2 + camera.global_position.x
		past_position.w = new_w_2 + Globals.camera_w
		
		# I update past position since this physics engine uses verlet, if I didn't update past position all of the particles would go flying when you rotated.
	# the same stuff I did for xw_angle, but now with zw.
	if Globals.zw_angle != zw_angle:
		var angle_change = Globals.zw_angle - zw_angle
		zw_angle = Globals.zw_angle
		var camera = get_parent().get_child(0)
		world_pos.z -= camera.global_position.z
		world_pos.w -= Globals.camera_w
		
		var new_z = (world_pos.z * cos(angle_change)) - (world_pos.w * sin(angle_change))
		var new_w = (world_pos.z * sin(angle_change)) + (world_pos.w * cos(angle_change))
		
		world_pos.z = new_z + camera.global_position.z
		world_pos.w = new_w + Globals.camera_w
		
		past_position.z -= camera.global_position.z
		past_position.w -= Globals.camera_w
		
		var new_z_2 = (past_position.z * cos(angle_change)) - (past_position.w * sin(angle_change))
		var new_w_2 = (past_position.z * sin(angle_change)) + (past_position.w * cos(angle_change))
		
		past_position.z = new_z_2 + camera.global_position.z
		past_position.w = new_w_2 + Globals.camera_w
	
	var slice_dist = get_slice_distance_to_camera()
	
	# out of slice update
	ana_slice.visible = Globals.camera_w < world_pos.w and Globals.camera_w > world_pos.w - Globals.hidden_axis_sight_range
	kata_slice.visible = Globals.camera_w > world_pos.w and Globals.camera_w < world_pos.w + Globals.hidden_axis_sight_range
	
	var transparency = abs(slice_dist - Globals.hidden_axis_sight_range) / Globals.hidden_axis_sight_range
	transparency *= Globals.transparency_multiplier
	
	if ana_slice.visible:
		ana_slice.material.albedo_color.a = transparency
	if kata_slice.visible:
		kata_slice.material.albedo_color.a = transparency
	
	# main sphere update
	main_sphere.visible = slice_dist < radius
	if slice_dist < radius:
		var radius = circle_height(radius, get_slice_distance_to_camera())
		main_sphere.scale = Vector3.ONE * radius
	
	# position update
	global_position = Vector3(world_pos.x, world_pos.y, world_pos.z)

func update_position(delta):
	var velocity = world_pos - past_position
	
	past_position = world_pos
	world_pos = world_pos + velocity + acceleration * delta * delta
	
	acceleration = Vector4.ZERO

func get_slice_distance_to_camera():
	return abs(Globals.camera_w - world_pos.w)

func circle_height(r:float, x: float): #returns the height of a circle of radius r, and point (x, 0). So I guess its really the height of a hemi circle at point x.
	return 2 * sqrt(r**2.0 - x**2.0)
