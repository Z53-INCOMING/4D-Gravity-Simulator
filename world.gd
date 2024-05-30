extends Node3D

var particles = 250

@onready var particle_scene = preload("res://physics_object_4d.tscn")

var spawn_radius = 3.0

@onready var label = $UI/Label

func start():
	for p in particles:
		spawn_particle(get_point_in_hypersphere(spawn_radius))

func spawn_particle(location: Vector4):
	var particle = particle_scene.instantiate()
	
	particle.world_pos = location
	particle.past_position = location
	add_child(particle)

func _process(delta):
	label.text = "FPS: " + str(Engine.get_frames_per_second())
	label.text += "\n"
	label.text += "Particles: " + str(particles)

func get_point_in_hypersphere(radius = 5.0) -> Vector4:
	var point = Vector4(randf_range(-radius, radius), randf_range(-radius, radius), randf_range(-radius, radius), randf_range(-radius, radius))
	
	if point.length_squared() > radius * radius:
		return get_point_in_hypersphere(radius)
	else:
		return point
