extends Node

var camera_w = 0.0

var hidden_axis_sight_range = 2.5

var physics_objects = []

var G = 1.0

var transparency_multiplier = 0.5

func _physics_process(delta):
	for p in physics_objects:
		for obj_id in range(p.id+1, physics_objects.size()):
			# gravity
			var distance = p.world_pos.distance_squared_to(physics_objects[obj_id].world_pos)
			var gravity_force = (1.0 / distance) * G
			var self_to_obj = (physics_objects[obj_id].world_pos - p.world_pos).normalized()
			p.acceleration += gravity_force * self_to_obj
			physics_objects[obj_id].acceleration += gravity_force * -self_to_obj
			
			# collisions
			if distance < 1.0:
				p.world_pos += -self_to_obj * (1.0 - distance) * 0.5 # 1.0 here and above is supposed to be the radius of the first object plus the radius of the second
				physics_objects[obj_id].world_pos += self_to_obj * (1.0 - distance) * 0.5
	
	# movement
	for p in physics_objects:
		p.update_position(delta)
