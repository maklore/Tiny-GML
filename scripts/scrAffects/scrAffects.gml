////****WIP****////


function tiny_affects() constructor {

	data = {
	    list : -1,
	    size : 0
	}

    /*
     * @desc Using this method you can add a buff or debuff to a DS list and have it affect the target instance. 
     * @param {Id.instance} _id     Instance ID of the target.
     * @param {string}      _key    Variable key to affect.
     * @param {string}      _name   Name of the effect.
     * @param {string}      _type   Type of the effect.
     * @param {real}        _time   Duration of the effect.
     * @param {real}        _value  Value of the effect.
     */
	add = function(_id, _key, _name, _type, _time, _value) {
		
		/*
		 * @desc Checks if name of an effect is already in the list.
		 */
		static check_name = function(_id, _name, _value) {
		    
			var _size = ds_list_size(_id);

			for (var i = 0; i < _size; ++i) {
			    
			    if struct_get(_id[| i], _name) == _value { return i; }
			    
			}
			
			return -1;
		}
		
		static frame_time = (1 / game_get_speed(gamespeed_fps)) / _time;
		
		if !ds_exists(data.list, ds_type_list) {
		    data.list = ds_list_create();
		}
        
        var _value_new = data.list[| i].type == "damage over time" or data.list[| i].type == "healing over time" ? _value * frame_time : _value;
        
		var _index_check = check_name(data.list, "name", _name);
				
		if _index_check > -1 {
		    data.list[| _index_check].time  = _time;
			data.list[| _index_check].value = _value_new;
		    exit;
		}
        
		ds_list_add(data.list, { 
		    time  : _time, 
		    iid   : _id, 
		    key   : _key,
		    name  : _name,
			type  : _type,
		    value : _value_new
		});
    
		data.size = ds_list_size(data.list);
	}
	
	
	countdown = function(_delta) {
	    
	    if !ds_exists(data.list, ds_type_list) { exit }
    
	    for (var i = 0; i < data.size; ++i) {
            
            var _instance = data.list[| i].iid;
	        var _var_key  = data.list[| i].key;
	        var _value    = data.list[| i].value;
	        var _time     = data.list[| i].time;
	        
	        if !instance_exists(_instance) or _time <= 0 or _instance[$ _var_key]  < 0 {
	            ds_list_delete(data.list, i);
	            data.size = ds_list_size(data.list);
	            continue
	        }
	        
			switch (data.list[| i].type) {
			
				case "damage over time" :
					_instance[$ _var_key] -= clamp(_value, 0, _instance[$ _var_key]);
				break;
				
				case "healing over time" :
					_instance[$ _var_key] += clamp(_value, 0, _instance[$ _var_key]);
				break;				
				
				case "slow" :
					_instance[$ _var_key] *= _value;
				break;
			}
			
			_time -= _delta;
                
	    }
	    if ds_list_empty(data.list) {
	        ds_list_destroy(data.list);
	        data.list = -1;
	        data.size = 0;
	    }
	}
}

#macro AFFECTS global.affects
AFFECTS = new tiny_affects();