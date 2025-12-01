/**
 * @desc This is a system for a announcing values onto the screen.
 */
function tiny_announce() constructor {
    
    //Initialize the values.
	static data = {
		font	: font_add("Arial", 32, false, false, 32, 128),
	    maximum : 5,
	    size    : 0,
	    length  : 74,												//Maximum character length before new line.
	    scale   : 1,												//Scale of the drawn string.
	    prompt  : -1,
	    time    : 4,												//Seconds
	    alpha   : 1,
	    time_pf : 1 / game_get_speed(gamespeed_fps),				//Time between frames
	    color   : [ #64c864, #c89600, #c83232],						//Green, Amber,  Red
	    type    : [0, 1, 2],										//news, warning, error
	    val     : {
	        text  : 0,
	        type  : 1,
	        time  : 2,
	        alpha : 3
	    }
	}
	font_enable_sdf(data.font, true);
	font_enable_effects(data.font, true, {
		dropShadowEnable: true,
	    dropShadowSoftness: 10,
	    dropShadowOffsetX: 4,
	    dropShadowOffsetY: 4,
		dropShadowAlpha: 1,
		outlineEnable: true,
		outlineDistance: 2,
		outlineColour: c_black
	});

    /**
     * @desc With this function you can send a stringed or a format alert to the broadcasting system. The types and colored text of systems are as follows: 0 (News - Green), 1 (Warning - Amber), and 2 (Error - Red).
     * @param {string} _string  The string message you wish to add broadcasting system.
     * @param {string} _type    The type of message you wish to broadcast (Default is 0).
     */
    alert = function(_string_or_format, _type = 0) {
		
        //If the type is not correct send a stringed alert to the broadcasting system and exit the function.
        if (_string_or_format == "") or !array_contains(data.type, _type) { alert("String is empty or type is invalid!", 1); exit; }
        
        if !ds_exists(data.prompt, ds_type_list) { data.prompt = ds_list_create(); }
        
        //Insert array into the first entry of the list: string (wrapped), type, timer to the broadcasting prompter.
		var _new_string = string(_string_or_format);
        var _string_length = string_length(_new_string);
        
	    if typeof(_string_or_format) == "string" and _string_length > data.length {
		    var _pos = data.length;
		    var _split_amount = round(_string_length / data.length);
		    for (var i = 0; i < _split_amount; ++i) {
		        _pos = string_last_pos_ext(" ", _new_string, _pos);
		        _new_string = string_insert("\n", _new_string, _pos);
		        _pos += data.length;
		    }
	    }

        ds_list_insert(data.prompt, 0, variable_clone([_new_string, _type, data.time, data.alpha]));
		
		//Get the size of the DS list with a max of maximum size.
        data.size = clamp(ds_list_size(data.prompt), 0, data.maximum);
        
        //If the size is greater (should not happen) or equal to the maximum size, delete the last entry.
        if data.size >= data.maximum { ds_list_delete(data.prompt, data.size); }
        
    }
   
    /**
    * @desc With this function messages will be broadcasted to the upper center of the screen. Add this to the Draw_GUI event.
    */
    broadcast = function() {
        
        //Initialize the draw position.
        static gui_x = display_get_gui_width() * 0.5;   //Center of the GUI width.
        static gui_y = display_get_gui_height() * 0.1;  //Upper part of the GUI height.
        
        //If there is no DS list exit the function.
        if !ds_exists(data.prompt, ds_type_list) { exit; }
        
        //If the font is not broadcasting font, set it. **WIP**
        if draw_get_font() != data.font { draw_set_font(data.font); }
		
		//Set the text alignment if it isn't centered top.
        if draw_get_halign() != fa_center { draw_set_halign(fa_center); };
        if draw_get_valign() != fa_top { draw_set_valign(fa_top); };
		
        var _string_y = 0;

        for (var i = 0; i < data.size; ++i) {
			
			//If there is an undefined entry exit the loop.
			if data.prompt[| i] == undefined { exit }
			
            //Adds the first entries string height to the current entry if there are more than one entry.
            _string_y = i > 0 ? _string_y + string_height(data.prompt[| 0][data.val.text]) * data.scale : 0;
			
            draw_text_transformed_color(gui_x, 
                                        gui_y + _string_y, 
                                        data.prompt[| i][data.val.text],
                                        data.scale,
                                        data.scale,
                                        0,
                                        data.color[data.prompt[| i][data.val.type]],
                                        data.color[data.prompt[| i][data.val.type]],
                                        data.color[data.prompt[| i][data.val.type]],
                                        data.color[data.prompt[| i][data.val.type]],
                                        data.prompt[| i][data.val.alpha]);
										
        }
		
		//Reduce the last entry's timer by set 'time' per frame.
        data.prompt[| data.size - 1][data.val.time] -= data.time_pf;
            
        //Reduce alpha to zero during the last second.
        if data.prompt[| data.size - 1][data.val.time] <= 1 { data.prompt[| data.size - 1][data.val.alpha] -= data.time_pf; }
            
        //Delete the entry once it's timer reaches zero.
        if data.prompt[| data.size - 1][data.val.time] <= 0 { 
			ds_list_delete(data.prompt, data.size - 1); 
			data.size = clamp(ds_list_size(data.prompt), 0, data.maximum) 
		}
        
        //If the list is empty, destroy it, and reset values.
        if ds_list_empty(data.prompt) { ds_list_destroy(data.prompt); data.prompt = -1; data.size = 0; }
    }
}

//INITIALIZE THE BROADCASTING SYSTEM
#macro ANNOUNCE global.announce
ANNOUNCE = new tiny_announce();