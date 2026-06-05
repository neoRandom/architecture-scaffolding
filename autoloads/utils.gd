extends Node


func string_to_vector2(input_string: String) -> Vector2:
	if input_string.length() < 3:
		return Vector2.ZERO

	var clean_string: String = input_string.replace("(", "").replace(")", "")
	var components: Array = clean_string.split(",")

	if components.size() >= 2:
		var x: float = float(components[0].strip_edges())
		var y: float = float(components[1].strip_edges())
		return Vector2(x, y)

	return Vector2.ZERO
