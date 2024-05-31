extends Node3D

var particles = 100

@onready var particle_scene = preload("res://physics_object_4d.tscn")

var spawn_radius = 5.0

@onready var label = $UI/Label

@onready var spawn_radius_label = $UI/Panel/Label2

@onready var particle_count_label = $UI/Panel/Label3

@onready var menu = $UI/Pause

func start():
	if $UI/Panel/DualSpawn.button_pressed:
		for p in floor(particles / 2.0):
			spawn_particle(get_point_in_hypersphere(spawn_radius) + Vector4(spawn_radius * 2.0, 0, 0, 0))
		for p in ceil(particles / 2.0):
			spawn_particle(get_point_in_hypersphere(spawn_radius) - Vector4(spawn_radius * 2.0, 0, 0, 0))
	else:
		for p in particles:
			spawn_particle(get_point_in_hypersphere(spawn_radius))

func spawn_particle(location: Vector4):
	var particle = particle_scene.instantiate()
	
	particle.world_pos = location
	particle.past_position = location
	add_child(particle)

func _process(delta):
	label.text = "FPS: " + str(Engine.get_frames_per_second())
	
	if Input.is_action_just_pressed("escape"):
		menu.visible = !menu.visible
		$Advanced3DCamera.enabled = !menu.visible

func get_point_in_hypersphere(radius = 5.0) -> Vector4:
	var point = Vector4(randf_range(-radius, radius), randf_range(-radius, radius), randf_range(-radius, radius), randf_range(-radius, radius))
	
	if point.length_squared() > radius * radius:
		return get_point_in_hypersphere(radius)
	else:
		return point

func _on_spawn_radius_slider_value_changed(value):
	spawn_radius = value
	spawn_radius_label.text = "Spawn Radius: (" + str(value) + ")"

func _on_particle_count_slider_value_changed(value):
	particles = value
	particle_count_label.text = "Particle Count (" + str(value) + ")"


func _on_start_button_down():
	start()
	$UI/Panel.visible = false
	label.visible = true


func _on_hidden_range_value_changed(value):
	Globals.hidden_axis_sight_range = value


func _on_transparency_multiplier_value_changed(value):
	Globals.transparency_multiplier = value


func _on_w_speed_value_changed(value):
	$Advanced3DCamera.speed = value
