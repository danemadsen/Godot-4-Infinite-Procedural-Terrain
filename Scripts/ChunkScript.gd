@tool
extends Node3D
class_name Chunk

var mesh_instance : MeshInstance3D
var noise : FastNoiseLite
var chunk_material = preload("res://Materials/GroundMaterial.tres")
var x
var z
var chunk_size
var chunk_height
var should_remove = false
var curve_value

func _init(_noise, x, z, chunk_size, chunk_height, curve_value):
	self.noise = _noise  # Accept noise instance from root node
	self.x = x
	self.z = z
	self.chunk_size = chunk_size
	self.chunk_height = chunk_height
	self.curve_value = curve_value

func _ready():
	generate_chunk()

func generate_chunk():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(chunk_size, chunk_size)
	plane_mesh.subdivide_depth = chunk_size * 0.5
	plane_mesh.subdivide_width = chunk_size * 0.5
	
	var surface_tool = SurfaceTool.new()
	var data_tool = MeshDataTool.new()
	surface_tool.create_from(plane_mesh, 0)
	var array_plane = surface_tool.commit()
	var error = data_tool.create_from_surface(array_plane, 0)
	
	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y += noise.get_noise_2d(vertex.x + self.x, vertex.z + self.z) * chunk_height
		vertex.y *= curve_value * pow(vertex.y, 2) - curve_value * vertex.y + 1.0
		data_tool.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()
	
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.create_trimesh_collision()
	mesh_instance.mesh.surface_set_material(0, chunk_material)
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mesh_instance)
