extends Node3D
class_name Chunk

var mesh_instance : MeshInstance3D
var noise : FastNoiseLite
var x
var z
var chunk_size
var chunk_height
var should_remove = false

func _init(noise, x, z, chunk_size, chunk_height):
	self.noise = noise
	self.x = x
	self.z = z
	self.chunk_size = chunk_size
	self.chunk_height = chunk_height

func _ready():
	generate_chunk()

func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 0.5
	plane_mesh.subdivide_width = chunk_size * 0.5
	plane_mesh.material = preload("res://materials/grass.material")
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_3d(vertex.x + x, vertex.y, vertex.z + z) * chunk_height
		data_tool.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
