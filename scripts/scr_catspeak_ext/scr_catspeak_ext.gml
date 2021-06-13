/* Catspeak GML Interface
 * ----------------------
 * Kat @katsaii
 */

function __catspeak_ext_build_arithmetic_global_interface_struct() {
	var vars = { };
	vars[$ "+"] = function(_l, _r) { return _l + _r };
	vars[$ "-"] = function(_l, _r) { return _r == undefined ? -_l : _l - _r };
	return vars;
}

/// @desc Returns arithmetic operators as a struct.
function catspeak_ext_arithmetic() {
	static vars = __catspeak_ext_build_arithmetic_global_interface_struct();
	return vars;
}

function __catspeak_ext_build_gml_global_interface_struct() {
	var vars = { };
	vars[$ "true"] = true;
	vars[$ "false"] = false;
	vars[$ "undefined"] = undefined;
	vars[$ "infinity"] = infinity;
	vars[$ "NaN"] = NaN;
	vars[$ "show_debug_message"] = show_debug_message;
	vars[$ "global"] = global;
	return vars;
}

/// @desc Returns the gml standard library as a struct.
function catspeak_ext_gml() {
	static vars = __catspeak_ext_build_gml_global_interface_struct();
	return vars;
}