extends Node
class_name Climate

var offset
var biome_1
var biome_2
var biome_3
var biome_4

func _init(y_offset, biome1, biome2, biome3, biome4):
	self.offset = y_offset
	self.biome_1 = biome1
	self.biome_2 = biome2
	self.biome_3 = biome3
	self.biome_4 = biome4

func get_weight(temperature):
	var weight = -((temperature + offset) * 3) ^ 2 + 1
	if(weight < 0):
		return 0
	else:
		return weight

func get_biome(biome_factor):
	if(biome_factor < -0.5):
		return biome_1
	elif(biome_factor < 0):
		return biome_2
	elif(biome_factor > 0):
		return biome_3
	elif(biome_factor > 0.5):
		return biome_4
