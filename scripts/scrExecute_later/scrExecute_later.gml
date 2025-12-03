/**
 * @desc This is a system for executing functions later.
 */
function tiny_execute_later() constructor {
	
	static data = {
		list : -1,
		size : 0
	}
  
	/**
	* @desc							This method adds a timer and a function to a DS list and executes it once the timer reaches zero. 
	* @param {real} _time			The time in seconds.	
	* @param {Function} _func	    The function to call later.
	*/
	add = function(_time, _func) {
	
    	if !ds_exists(data.list, ds_type_list) {
    	    data.list = ds_list_create();
    	}
    	
    	ds_list_insert(data.list, 0, { func : _func, time : _time  });
    	
    	data.size = ds_list_size(data.list); 
	
	}
  
	/**
	 * @desc This method counts down for each item in the list until it reaches zero, then executes the alter, and removes it from the list.
	 */
	countdown = function() {
		if !ds_exists(data.list, ds_type_list) { exit }
		var _delta_frame = (delta_time / game_get_speed(gamespeed_microseconds)) / game_get_speed(gamespeed_fps);
		for (var i = 0; i < data.size; ++i) {
      
		    if i > data.size { break }
      
		    data.list[| i].time -= _delta_frame;
      
		    if data.list[| i].time <= 0 {
			    data.list[| i].func();
			    ds_list_delete(data.list, i);
			    data.size = ds_list_size(data.list);
			    i--;
		    }
		}
		if ds_list_empty(data.list) {
		    ds_list_destroy(data.list);
		    data.list = -1;
		    data.size = 0;
		}
	}
}

#macro EXECUTE global.execute
EXECUTE = new tiny_execute_later();