extends Node
class_name Climate

var climate_name
var offset
var biome_1
var biome_2
var biome_3
var biome_4

func _init(text, c_offset, biome1, biome2, biome3, biome4):
	self.climate_name = text
	self.offset = c_offset
	self.biome_1 = biome1
	self.biome_2 = biome2
	self.biome_3 = biome3
	self.biome_4 = biome4

func get_biome(biome_factor):
	if(biome_factor < -0.5):
		return biome_1
	elif(biome_factor < 0):
		return biome_2
	elif(biome_factor > 0):
		return biome_3
	elif(biome_factor > 0.5):
		return biome_4
