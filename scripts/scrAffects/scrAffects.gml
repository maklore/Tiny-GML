////****WIP****////


function tiny_affects() constructor {

	data = {
	    list : -1,
	    size : 0
	}


	add = function(_id, _key, _name, _type, _time, _value) {
		
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
        
        var _value_new = 0;
        
        switch (data.list[| i].type) {
            
            case "damage over time" :
                _value_new = _value * frame_time;
            break;
            
            case "healing over time" :
                _value_new = _value * frame_time;
            break;
            
            case "slow" :
                _value_new = _value;
            break;
        }
        
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
        
	        data.list[| i].time -= _delta;
            
			switch (data.list[| i].type) {
			
				case "damage over time" :
					data.list[| i].iid[$ data.list[| i].key] -= clamp(data.list[| i].value, 0, data.list[| i].iid[$ data.list[| i].key]);
				break;
				
				case "healing over time" :
					data.list[| i].iid[$ data.list[| i].key] += clamp(data.list[| i].value, 0, data.list[| i].iid[$ data.list[| i].key]);
				break;				
				
				case "slow" :
					data.list[| i].iid[$ data.list[| i].key] *= data.list[| i].value;
				break;
			}
		
		
	        if data.list[| i].time <= 0 or data.list[| i].iid[$ data.list[| i].key] < 0 {
	            ds_list_delete(data.list, i);
	            data.size = ds_list_size(data.list);
	            continue
	        }
                
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