/**
 * @desc This function is a constructor for an instance variable change later system.
 */
function tiny_alter_later() constructor {
	
	data = {
	    list : -1,
	    size : 0
	}
	
	/**
	* @desc							This method adds a timer and a method/function to a DS list and calls it when the timer finishes. 
	* @param {real} _time			The time in seconds.
	* @param {id} _id				The instance id that contains the variable.
	* @param {string} _name			The variable name as a string.
	* @param {any} _value			The value to be set.
	*/
	add = function(_time, _id, _name, _value) {
    
	    if !ds_exists(data.list, ds_type_list) {
	        data.list = ds_list_create();
	    }
    
	    ds_list_insert(data.list, 0, { 
	        time  : _time, 
	        ids   : _id, 
	        name  : _name, 
	        value : _value 
	    });
    
	    data.size = ds_list_size(data.list);
	
	}
	
	/**
	 * @desc This method counts down for each item in the list until it reaches zero, then executes the alter, and removes it from the list.
	 */
	countdown = function() {
		if !ds_exists(data.list, ds_type_list) { exit }
		var _delta_frame = (delta_time / game_get_speed(gamespeed_microseconds)) / game_get_speed(gamespeed_fps);
		for (var i = 0; i < data.size; ++i) {
  
		    if i > data.size or data[| i] == undefined { show_debug_message("Broke") break }
  
		    data.list[| i].time -= _delta_frame;
  
		    if data.list[| i].time <= 0 {
		        variable_instance_set(data.list[| i].ids, data.list[| i].name, data.list[| i].value);
		        ds_list_delete(data.list, i);
		        data.size = ds_list_size(data.list);
		    }
        
		}
		if ds_list_empty(data.list) {
		    ds_list_destroy(data.list);
		    data.list = -1;
		    data.size = 0;
		}
	}
}

#macro ALTER global.alter
ALTER = new tiny_alter_later();