@tool
extends Object
class_name ClosestPointOnCurveMeta
var before_segment : int
var point_position : Vector2
var local_point_position : Vector2

func _init(bs : int, pp : Vector2, lpp : Vector2):
	before_segment = bs
	point_position = pp
	local_point_position = lpp
