/**
 * @desc This is a system for changing instance variables later.
 */
function tiny_change_later() constructor {
	
	static data = {
	    list : -1,
	    size : 0
	}
	
	/**
	* @desc							This method adds a timer, instance id, variable name, and a value to a DS list and changes it once the timer reaches zero. 
	* @param {real} _time			The time in seconds.
	* @param {id} _id				The instance id that contains the variable.
	* @param {string} _name			The variable name as a string.
	* @param {any} _value			The value to be set.
	*/
	static add = function(_time, _id, _name, _value) {
    
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
	 * @desc This method counts down for each item in the list until it reaches zero, then executes the change, and removes it from the list.
	 */
	static countdown = function() {
		if !ds_exists(data.list, ds_type_list) { exit }
		var _delta_frame = (delta_time / game_get_speed(gamespeed_microseconds)) / game_get_speed(gamespeed_fps);
		for (var i = 0; i < data.size; ++i) {
  
		    if i > data.size or data[| i] == undefined { break; }
  
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

#macro CHANGE global.change
CHANGE = new tiny_change_later();