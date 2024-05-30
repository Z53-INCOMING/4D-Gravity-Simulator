extends Node3D

var particles = 1000

@onready var particle_scene = preload("res://physics_object_4d.tscn")

var spawn_boundary = 5.0

func _ready():
	#spawn_particle(Vector4(0, 0, 0, -1))
	#spawn_particle(Vector4(0, 0, 0, 1))
	for p in particles:
		spawn_particle(Vector4(randf_range(-spawn_boundary, spawn_boundary), randf_range(-spawn_boundary, spawn_boundary), randf_range(-spawn_boundary, spawn_boundary), randf_range(-spawn_boundary, spawn_boundary)))

func spawn_particle(location: Vector4):
	var particle = particle_scene.instantiate()
	
	particle.world_pos = location
	particle.past_position = location
	add_child(particle)
