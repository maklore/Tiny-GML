/**
  * @desc This function inserts a new line searching backwards for the first space it finds from the set length. The string splits into new lines equal to the string length divided by the max length rounded.
  * @param {string} _string	The string to insert new lines.
  * @param {real}   _length	The maximum character length before a new line.
  */
function tiny_wrap(_string, _length) {
	var _string_length = string_length(_string);
    if _string_length <= _length { return _string } 
    var _pos = _length;
    var _new_string = string_copy(_string, 1, _string_length);
    var _split_amount = round(_string_length / _length);
    for (var i = 0; i < _split_amount; ++i) {
        _pos = string_last_pos_ext(" ", _new_string, _pos);
        _new_string = string_insert("\n", _new_string, _pos);
        _pos += _length;
    }
    return _new_string;
}

/**
 * @desc This function saves the "most useful" built in variables, and each* instance variables of all but the excluded objects to a json file named after the room when called. *Not methods.
 * @param {array} _exclude_array The array containing the object index to exclude. Default is empty.
 */
function tiny_save(_exclude_array = []) {
	var instance = {};
	instance_activate_all();
	
	for (var i = 0; i < instance_count; ++i;) {
		var _id = instance_id[i];
		
	    if !instance_exists(_id) or array_contains(_exclude_array, _id.object_index) { continue }
		
	    var _get_vars  = variable_instance_get_names(_id);
	    var _get_count = array_length(_get_vars);
	    var _data      = {};
	    for (var ii = 0; ii < _get_count; ++ii) {
	        var _data_get = variable_instance_get(_id, _get_vars[ii]);
	        variable_struct_set(_data, _get_vars[ii], _data_get);
	    }
	    var _instance_var = {
	        Object     : variable_instance_get(_id, "object_index"),
	        Sprite     : variable_instance_get(_id, "sprite_index"),
	        Subimg     : variable_instance_get(_id, "image_index"),
	        Angle      : variable_instance_get(_id, "image_angle"),
	        Xscale     : variable_instance_get(_id, "image_xscale"),
	        Yscale     : variable_instance_get(_id, "image_yscale"),
	        Depth      : variable_instance_get(_id, "depth"),
	        Visible    : variable_instance_get(_id, "visible"),
	        Solid      : variable_instance_get(_id, "solid"),
	        Layer      : variable_instance_get(_id, "layer"),
	        X          : variable_instance_get(_id, "x"),
	        Y          : variable_instance_get(_id, "y"),
	        Variables  : variable_clone(_data)
	    }
		variable_struct_set(instance, i, _instance_var);
	}

	var _json_save = json_stringify(instance);
	var _get_room  = room_get_name(room);
	var _save_file = file_text_open_write(_get_room);
	file_text_write_string(_save_file, _json_save);
	file_text_close(_save_file);
}

/**
 * @desc This function loads each saved variable from a json file named after a room, and destroys each instance and remakes them while inserting the saved data.
 * @param {array} _exclude_array The array containing the object index to exclude. Default is empty.
 */
function tiny_load(_exclude_array = []) {
	
	var _get_room  = room_get_name(room);
	if !file_exists(_get_room) { exit }
	
	instance_activate_all();
	
	for (var d = 0; d < instance_count; ++d) {
		if !array_contains(_exclude_array, instance_id[d].object_index) {
			instance_destroy(instance_id[d])	
		}
	}
	
	var _open_file = file_text_open_read(_get_room);
	var _read_file = file_text_read_string(_open_file);
	var _id        = json_parse(_read_file);
	file_text_close(_open_file);
	
	var _struct_key = variable_struct_get_names(_id);
	var _count_key  = variable_struct_names_count(_id);
	for (var i = 0; i < _count_key; ++i) {
		var create_instance = instance_create_layer(_id[$ _struct_key[i]].X, 
													_id[$ _struct_key[i]].Y, 
													_id[$ _struct_key[i]].Layer, 
													_id[$ _struct_key[i]].Object, 
													_id[$ _struct_key[i]].Variables);
													
		variable_instance_set(create_instance, "image_angle",  _id[$ _struct_key[i]].Angle);
		variable_instance_set(create_instance, "image_xscale", _id[$ _struct_key[i]].Xscale);
		variable_instance_set(create_instance, "image_yscale", _id[$ _struct_key[i]].Yscale);
		variable_instance_set(create_instance, "image_index",  _id[$ _struct_key[i]].Subimg);
		variable_instance_set(create_instance, "depth", 	   _id[$ _struct_key[i]].Depth);
		variable_instance_set(create_instance, "visible",	   _id[$ _struct_key[i]].Visible);
		variable_instance_set(create_instance, "solid", 	   _id[$ _struct_key[i]].Solid);
		variable_instance_set(create_instance, "layer", 	   _id[$ _struct_key[i]].Layer);
	}
}