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

func _ready():
	kata_slice.radius = radius - 0.01
	ana_slice.radius = radius - 0.01
	Globals.physics_objects.append(self)
	id = Globals.physics_objects.size() - 1

func _process(delta):
	# out of slice update
	ana_slice.visible = Globals.camera_w < world_pos.w and Globals.camera_w > world_pos.w - Globals.hidden_axis_sight_range
	kata_slice.visible = Globals.camera_w > world_pos.w and Globals.camera_w < world_pos.w + Globals.hidden_axis_sight_range
	
	var transparency = abs(get_slice_distance_to_camera() - Globals.hidden_axis_sight_range) / Globals.hidden_axis_sight_range
	transparency *= Globals.transparency_multiplier
	
	if ana_slice.visible:
		ana_slice.material.albedo_color.a = transparency
	if kata_slice.visible:
		kata_slice.material.albedo_color.a = transparency
	
	# main sphere update
	main_sphere.visible = get_slice_distance_to_camera() < radius
	if main_sphere.visible:
		main_sphere.radius = circle_height(radius, get_slice_distance_to_camera()) * 0.5
	
	# position update
	global_position = Vector3(world_pos.x, world_pos.y, world_pos.z)

func update_position(delta):
	var velocity = world_pos - past_position
	
	past_position = world_pos
	world_pos = world_pos + velocity + acceleration * delta * delta
	
	acceleration = Vector4.ZERO

func get_slice_distance_to_camera():
	return abs(Globals.camera_w - world_pos.w)

func circle_height(r:float, x: float):
	return 2 * sqrt(r**2.0 - x**2.0)
